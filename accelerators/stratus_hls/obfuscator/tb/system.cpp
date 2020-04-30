/* Copyright 2018 Columbia University, SLD Group */

#include "utils.h"

#include "fpdata.hpp"
#include "system.hpp"
#include "validation.hpp"

#include "obfuscator_directives.hpp"

#ifdef ENABLE_DIFT_SUPPORT
// Tag used for the input
#define SRC_TAG 0x0100DEAD
// Tag used for the output
#define DST_TAG 0xBEEF0100
// Decomment to see leakage
#define ENABLE_WRONG_FIRST_TAG
#endif // ENABLE_DIFT_SUPPORT

#ifdef ENABLE_WRONG_FIRST_TAG
#define CANARIN 0xBEEFFFFF
#endif // ENABLE_WRONG_FIRST_TAG

#define MAX(x, y) (((x) < (y)) ? (y) : (x))

// -- Processes

void system_t::config_proc()
{
#ifdef ENABLE_DIFT_SUPPORT
    dift_conf_info_t config;
#else // DISABLE_DIFT_SUPPORT
    conf_info_t config;
#endif // ENABLE_DIFT_SUPPORT

    // Reset

    {
        conf_info.write(config);
        conf_done.write(false);
        wait();
    }

    // Config

    {
        // Provide the input data
        load_memory(); wait();

#ifdef ENABLE_DIFT_SUPPORT
        config.src_tag = SRC_TAG;
        config.dst_tag = DST_TAG;
        config.tag_off = (uint32_t) log2(tag_offset);
#endif // ENABLE_DIFT_SUPPORT

        config.ld_offset = 0;
        config.st_offset = index;

        config.num_rows = num_rows;
        config.num_cols = num_cols;

        config.i_row_blur = i_row_blur;
        config.i_col_blur = i_col_blur;
        config.e_row_blur = e_row_blur;
        config.e_col_blur = e_col_blur;

        this->conf_info.write(config);
        this->conf_done.write(true);
    }

    // Compute

    {
        // Print information about begin time
        sc_time begin_time = sc_time_stamp();
        ESP_REPORT_TIME(begin_time, "BEGIN - obfuscator");

        // Wait the the termination of the accelerator
        do { wait(); } while (!this->acc_done.read());

        // Check the error code reported by the accelerator
        debug_info_t debug_code = debug.read();
        ESP_REPORT_INFO("exit code of obfuscator is %u", debug_code);

        // Print information about end time
        sc_time end_time = sc_time_stamp();
        ESP_REPORT_TIME(end_time, "END - obfuscator");

        // Log the latency for Stratus HLS
        sc_time latency = end_time - begin_time;
        esc_log_latency(this->clock_cycle(latency));
        wait(); this->conf_done.write(false);
    }

    // Conclude

    {
        dump_memory(); // store the output image in the data structure

        validate(); // check the results with the golden model

#ifndef ENABLE_WRONG_FIRST_TAG

        write_image_to_file(out_image, num_rows,
                num_cols, esc_argv()[2]);

        delete[] out_image_gold;

        delete[] out_image;

#endif // ENABLE_WRONG_FIRST_TAG

        free(in_image);

        sc_stop();
    }
}

// -- Functions

void system_t::load_memory()
{

    //  Memory allocation:
    //
    //  =============================  ^
    //  |            input          |  | num_rows * num_cols
    //  =============================  ^
    //  |           output          |  | num_rows * num_cols
    //  =============================  v

#ifdef ENABLE_DIFT_SUPPORT
    uint32_t tag_off;
#endif // ENABLE_DIFT_SUPPORT

    index = 0;

#ifdef ENABLE_DIFT_SUPPORT
    if (esc_argc() != 9)
    {
        ESP_REPORT_INFO("usage: %s <in-file> <out-file> <i_row_blur>"
                " <i_col_blur> <e_row_blur> <e_col_blur> <dma-chunk>"
                " <tag-offset>\n", esc_argv()[0]);
#else // DISABLE_DIFT_SUPPORT
    if (esc_argc() != 7)
    {
        ESP_REPORT_INFO("usage: %s <in-file> <out-file> <i_row_blur>"
                " <i_col_blur> <e_row_blur> <e_col_blur>",
                esc_argv()[0]);
#endif // ENABLE_DIFT_SUPPORT
        sc_stop();
    }

    i_row_blur = atoi(esc_argv()[3]);
    i_col_blur = atoi(esc_argv()[4]);
    e_row_blur = atoi(esc_argv()[5]);
    e_col_blur = atoi(esc_argv()[6]);
#ifdef ENABLE_DIFT_SUPPORT
    tag_offset = tag_off = atoi(esc_argv()[8]);
#endif // ENABLE_DIFT_SUPPORT

    if (read_image_from_file(&in_image, &num_rows, &num_cols, esc_argv()[1]) < 0)
    {
        ESP_REPORT_ERROR("reading image failed!");
        sc_stop();
    }

    i_col_blur = round_down(i_col_blur, 1 << DMA_CHUNK);
    e_col_blur = round_up(e_col_blur, 1 << DMA_CHUNK, num_cols);

#ifdef ENABLE_DIFT_SUPPORT
    ESP_REPORT_INFO("tag offset %u", tag_offset);
#endif // ENABLE_DIFT_SUPPORT
    ESP_REPORT_INFO("dma chunk %u", 1 << DMA_CHUNK);
    ESP_REPORT_INFO("row_blur %u %u", i_row_blur, e_row_blur);
    ESP_REPORT_INFO("col_blur %u %u", i_col_blur, e_col_blur);
    ESP_REPORT_INFO("number of rows %u", num_rows);
    ESP_REPORT_INFO("number of cols %u", num_cols);

    for (uint32_t row = 0; row < num_rows; ++row)
    {
        for (uint32_t col = 0; col < num_cols; ++col)
        {
            uint32_t i = row * num_cols + col;

            this->mem[index++] = fp2bv<FPDATA, 32>(in_image[i].val);

            // ESP_REPORT_INFO("input[%u] = %08x (%f)", index-1,
            //     this->mem[index-1].to_uint(), in_image[i].val);

#ifdef ENABLE_DIFT_SUPPORT
	        if (!(--tag_off))
            {
                this->mem[index++] = sc_dt::sc_bv<32>(SRC_TAG);
                tag_off = tag_offset;
            }
#endif // ENABLE_DIFT_SUPPORT
        }
    }

#ifdef ENABLE_DIFT_SUPPORT
#ifdef ENABLE_WRONG_FIRST_TAG

    for (uint32_t i = index; i < MEM_SIZE; ++i)
    {
        // Initialize the memory with a rand value
        this->mem[i] = sc_dt::sc_bv<32>(CANARIN);
    }

    // To measure leakage of info
    this->mem[tag_offset] = ~SRC_TAG;
#endif // ENABLE_WRONG_FIRST_TAG
#endif // ENABLE_DIFT_SUPPORT

    ESP_REPORT_INFO("load memory completed");
}

void system_t::dump_memory()
{
#ifndef ENABLE_WRONG_FIRST_TAG

    sc_dt::sc_bv<DMA_WIDTH> data;
#ifdef ENABLE_DIFT_SUPPORT
    uint32_t tag_off = tag_offset;
#endif // ENABLE_DIFT_SUPPORT

    out_image = new image_t[num_rows * num_cols];

    for (uint32_t row = 0; row < num_rows; ++row)
    {
        for (uint32_t col = 0; col < num_cols; ++col)
        {
            uint32_t offset = row * num_cols + col;

            out_image[offset].val = bv2fp<FPDATA, 32>(this->mem[index++]);

#ifdef ENABLE_DIFT_SUPPORT
	        if (!(--tag_off))
            {
                assert(this->mem[index] == DST_TAG);
                tag_off = tag_offset;
                index++;
            }
#endif // ENABLE_DIFT_SUPPORT
        }
    }

    ESP_REPORT_INFO("dump memory completed");

#else // DISABLE_WRONG_FIRST_TAG

    uint32_t i = index;
    while ((this->mem[i] != sc_dt::sc_bv<32>(CANARIN))
       && (i < (index + num_rows * num_cols))) i++;

    ESP_REPORT_INFO("leakage of #%d out of #%d (%.2lf%%)",
      (i - index), num_rows * num_cols, ((((double) (i -
      index)) / (double) (num_rows * num_cols)) * 100.0));

#endif // ENABLE_WRONG_FIRST_TAG
}

int system_t::validate()
{
#ifndef ENABLE_WRONG_FIRST_TAG

    double rel_error = 0.0;
    double avg_error = 0.0;
    double max_error = 0.0;

    uint32_t tot_errors = 0;

    out_image_gold = new image_t[num_rows * num_cols];

    // Call the programmer's view function
    obfuscate(in_image, out_image_gold, num_rows, num_cols,
       i_row_blur, i_col_blur, e_row_blur, e_col_blur, KERNEL_SIZE);

    for (uint32_t row = 0; row < num_rows; ++row)
    {
        for (uint32_t col = 0; col < num_cols; ++col)
        {
            uint32_t i = row * num_cols + col;

            if (check_error_threshold(out_image[i].val,
                  out_image_gold[i].val, rel_error))
            {
                if (tot_errors < REPORT_THRESHOLD)
                    {
                        ESP_REPORT_INFO("obfuscator[%u, %u] = %f (%f)",
                       row, col-1, out_image[i-1].val, out_image_gold[i-1].val);
                        ESP_REPORT_INFO("obfuscator[%u, %u] = %f (%f)",
                       row, col, out_image[i].val, out_image_gold[i].val); }
                tot_errors++;
            }

            // Tracking the maximum error w.r.t. the programmer's view
            if (rel_error > max_error) { max_error = rel_error; }

            // Tracking the average error w.r.t. the programmer's view
            avg_error += rel_error;
        }
    }

    avg_error /= (double) (num_rows * num_cols);
    ESP_REPORT_INFO("errors #%d out of #%d", tot_errors, num_rows * num_cols);
    ESP_REPORT_INFO("average error: %.2lf%%", avg_error * 100);
    ESP_REPORT_INFO("maximum error: %.2lf%%", max_error * 100);

    if (tot_errors > MAX_ERROR_ACCEPTED)
        { ESP_REPORT_ERROR("validation failed!"); }
    else
        { ESP_REPORT_INFO("validation succeeded!"); }

#endif // ENABLE_WRONG_FIRST_TAG

    return 0;
}
