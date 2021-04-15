// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "fft2_conf_info.hpp"
#include "fft2_debug_info.hpp"
#include "fft2.hpp"
#include "fft2_directives.hpp"
#include "fft2_test.hpp"

#include "esp_templates.hpp"

#define MAX_BUFFERS_FULL 2
const size_t MEM_SIZE = MAX_BUFFERS_FULL * (2 * 262144) / (DMA_WIDTH/8);

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "fft2_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    fft2_wrapper *acc;
#else
    fft2 *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
    {
        // ACC
#ifdef CADENCE
        acc = new fft2_wrapper("fft2_wrapper");
#else
        acc = new fft2("fft2_wrapper");
#endif
        // Binding ACC
        acc->clk(clk);
        acc->rst(acc_rst);
        acc->dma_read_ctrl(dma_read_ctrl);
        acc->dma_write_ctrl(dma_write_ctrl);
        acc->dma_read_chnl(dma_read_chnl);
        acc->dma_write_chnl(dma_write_chnl);
        acc->conf_info(conf_info);
        acc->conf_done(conf_done);
        acc->acc_done(acc_done);
        acc->debug(debug);

        /* <<--params-default-->> */
        logn_samples = 12;
        num_samples = (1 << logn_samples);
        num_ffts = 4;
        do_inverse = 0;
        do_shift = 0;
        scale_factor = 1;
    }

    // Processes

    // Configure accelerator
    void config_proc();

    // Load internal memory
    void load_memory();

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Accelerator-specific data
    /* <<--params-->> */
    int32_t logn_samples;
    int32_t num_samples;
    int32_t num_ffts;
    int32_t do_inverse;
    int32_t do_shift;
    int32_t scale_factor;

    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t out_size;
    float *in;
    float *out;
    float *gold;

    // Other Functions
};

#endif // __SYSTEM_HPP__
