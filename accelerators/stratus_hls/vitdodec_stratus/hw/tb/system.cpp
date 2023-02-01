// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include <random>
#include <sstream>
#include "system.hpp"

static int8_t* goldMem;
int8_t * gold_in;
int8_t * gold_out;

static const unsigned char PARTAB[256] = {
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
         0, 1, 1, 0, 1, 0, 0, 1,
         0, 1, 1, 0, 1, 0, 0, 1,
         1, 0, 0, 1, 0, 1, 1, 0,
}; 

// Helper random generator
static std::random_device rd;
static std::mt19937 gen(rd());
//static std::mt19937 gen(0);
static std::uniform_int_distribution<int> dis(0,1);


#include "do_decoding.c" 

static void init_random_distribution(void)
{
    // const int LO = 0;
    // const int HI = 1;

    // gen = new std::mt19937(rd());
    // dis = new std::uniform_int_distribution<int>(LO, HI);
}

static int gen_random_bit(void)
{
    return dis(gen);
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
        conf_info_t config;
        // Custom configuration
        /* <<--params-->> */
        config.cbps = cbps;
        config.ntraceback = ntraceback;
        config.data_bits = data_bits;

        wait(); conf_info.write(config);
        conf_done.write(true);
    }

    ESP_REPORT_INFO("config done");

    // Compute
    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - vitdodec");

        // Wait the termination of the accelerator
        do { wait(); } while (!acc_done.read());
        debug_info_t debug_code = debug.read();

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - vitdodec");

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
        sc_stop();
    }
}

// Functions
void system_t::load_memory()
{
    // Optional usage check
#ifdef CADENCE
    if (esc_argc() != 1)
    {
        ESP_REPORT_INFO("usage: %s\n", esc_argv()[0]);
        sc_stop();
    }
#endif

    // Input data and golden output (aligned to DMA_WIDTH makes your life easier)
#if (DMA_WORD_PER_BEAT == 0)
    in_words_adj = 24852;
    out_words_adj = 18585;
#else
    in_words_adj = round_up(24852, DMA_WORD_PER_BEAT);
    out_words_adj = round_up(18585, DMA_WORD_PER_BEAT);
#endif

    in_size = in_words_adj * (1);
    out_size = out_words_adj * (1);

    ESP_REPORT_INFO("in_size = %u  and out_size = %u", in_size, out_size);

    goldMem = new int8_t[in_size]; // The Gold runs inputs
    gold    = new int8_t[out_size];// The Gold runs output
    // Pre-set the gold output to zeros (a known state)
    for (int tti = 0; tti < out_size; tti++) { 
        gold[tti] = 0;
    }
    //testMem = new int8_t[in_size+out_size];
    in = new int8_t[in_size];

    int mi = 0;
    unsigned char depunct_ptn[6] = {1, 1, 0, 0, 0, 0}; // PATTERN_1_2 Extended with zeros

    ESP_REPORT_INFO("Setting up goldMem\n");
    {
        int imi = 0;
        gold_in = &goldMem[imi]; // new int8_t[in_size];
        int polys[2] = { 0x6d, 0x4f };
        for(int i=0; i < 32; i++) {
            goldMem[imi] = (polys[0] < 0) ^ PARTAB[(2*i) & abs(polys[0])] ? 1 : 0;
            goldMem[imi+32] = (polys[1] < 0) ^ PARTAB[(2*i) & abs(polys[1])] ? 1 : 0;
            imi++;
        }
        if (imi != 32) { ESP_REPORT_INFO("ERROR : imi = %u and should be 32\n", imi); }
        imi += 32;

        //ESP_REPORT_INFO("Set up brtab27\n");
        if (imi != 64) { ESP_REPORT_INFO("ERROR : imi = %u and should be 64\n", imi); }
        // imi = 64;
        for (int ti = 0; ti < 6; ti ++) {
            goldMem[imi++] = depunct_ptn[ti];
        }
        //ESP_REPORT_INFO("Set up depunct\n");
        goldMem[imi++] = 0;
        goldMem[imi++] = 0;
        if (imi != 72) { ESP_REPORT_INFO("ERROR : imi = %u and should be 72\n", imi); }
        // imi = 72
        //ESP_REPORT_INFO("Set up padding\n");

        for (int j = imi; j < in_size; j++) {
            int bval = gen_random_bit(); // & 0x01;
            //ESP_REPORT_INFO("Setting up goldMem[%d] = %d\n", j, bval);
            goldMem[j] = bval;
        }
        //ESP_REPORT_INFO("Set up inputs\n");

        // gold_out = &goldMem[in_size]; //imi];
        // gold = gold_out;
        // for (int j = in_size; j < (in_size + out_size); j++)
        //     goldMem[j] = 0;
        //ESP_REPORT_INFO("Set up outputs\n");
    }

    // Set up the input memory (copy gold...)
    ESP_REPORT_INFO("Setting up input memory\n");
    {
        int imi = 0;
        for (int j = 0; j < in_size; j++) {
            in[j] = goldMem[j];
        }
    }

#if(0) 
    {
        printf("\n Gold in     = ");
        int limi = 0;
        for (int li = 0; li < 32; li++) {
            printf("%u", gold_in[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n      brtb1    ");
        for (int li = 0; li < 32; li++) {
            printf("%u", gold_in[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n      depnc    ");
        for (int li = 0; li < 8; li++) {
            printf("%u", gold_in[limi++]);
        }
        printf("\n      depdta   ");
        for (int li = 0; li < 32; li++) {
            printf("%u", gold_in[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n\n");

        printf(" memory in   = ");
        limi = 0;
        for (int li = 0; li < 32; li++) {
            printf("%u", in[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n      brtb1    ");
        for (int li = 0; li < 32; li++) {
            printf("%u", in[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n      depnc    ");
        for (int li = 0; li < 8; li++) {
            printf("%u", in[limi++]);
        }
        printf("\n      depdta   ");
        for (int li = 0; li < 32; li++) {
            printf("%u", in[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n");
        printf("\n Gold Mem    = ");
        limi = 0;
        for (int li = 0; li < 32; li++) {
            printf("%u", goldMem[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n      brtb1    ");
        for (int li = 0; li < 32; li++) {
            printf("%u", goldMem[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n      depnc    ");
        for (int li = 0; li < 8; li++) {
            printf("%u", goldMem[limi++]);
        }
        printf("\n      depdta   ");
        for (int li = 0; li < 32; li++) {
            printf("%u", goldMem[limi++]);
            if ((li % 8) == 7) { printf(" "); }
        }
        printf("\n\n");
    }
#endif
    // Compute the gold output in software!
    ESP_REPORT_INFO("Computing Gold output\n");
    do_decoding(data_bits, cbps, ntraceback, (unsigned char *)goldMem, (unsigned char*)gold);

#if(0)
    {
        int limi = 0;
        printf("\n Gold        = ");
        limi = 0;
        for (int li = 0; li < 32; li++) {
            printf("%u", gold[limi++]);
            if ((li % 8) == 7) { std::cout << " "; }
        }
        printf("\n\n");
    }
#endif

    // Memory initialization:
#if (DMA_WORD_PER_BEAT == 0)
    for (int i = 0; i < in_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            mem[DMA_BEAT_PER_WORD * i + j] = data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH);
    }
#else
    for (int i = 0; i < in_size / DMA_WORD_PER_BEAT; i++)  {
        sc_dt::sc_bv<DMA_WIDTH> data_bv(in[i]);
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
            data_bv.range((j+1) * DATA_WIDTH - 1, j * DATA_WIDTH) = in[i * DMA_WORD_PER_BEAT + j];
        mem[i] = data_bv;
    }
#endif

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
    // Get results from memory
    out = new int8_t[out_size];
    uint32_t offset = in_size;

#if (DMA_WORD_PER_BEAT == 0)
    offset = offset * DMA_BEAT_PER_WORD;
    for (int i = 0; i < out_size; i++)  {
        sc_dt::sc_bv<DATA_WIDTH> data_bv;

        for (int j = 0; j < DMA_BEAT_PER_WORD; j++)
            data_bv.range((j + 1) * DMA_WIDTH - 1, j * DMA_WIDTH) = mem[offset + DMA_BEAT_PER_WORD * i + j];

        out[i] = data_bv.to_int64();
    }
#else
    offset = offset / DMA_WORD_PER_BEAT;
    for (int i = 0; i < out_size / DMA_WORD_PER_BEAT; i++)
        for (int j = 0; j < DMA_WORD_PER_BEAT; j++)
            out[i * DMA_WORD_PER_BEAT + j] = mem[offset + i].range((j + 1) * DATA_WIDTH - 1, j * DATA_WIDTH).to_int64();
#endif

    ESP_REPORT_INFO("dump memory completed");
}

int system_t::validate()
{
    // Check for mismatches
    uint32_t errors = 0;

    for (int i = 0; i < 1; i++)
        for (int j = 0; j < 18585; j++)
            if (gold[i * out_words_adj + j] != out[i * out_words_adj + j]) {
                if (errors < 9) { 
                    ESP_REPORT_INFO("  Validation Mismatch : [%d] gold vs out = %d vs %d  %p - %x vs %p - %x", j, gold[j], out[j], gold, (&(gold[j]) - gold), out, (&out[j] - out));
                }
                errors++;
            }

    delete [] in;
    delete [] out;
    delete [] gold;
    delete [] goldMem;

    return errors;
}
