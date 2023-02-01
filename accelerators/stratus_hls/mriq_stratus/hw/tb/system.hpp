// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "mriq_conf_info.hpp"
#include "mriq_debug_info.hpp"
#include "mriq.hpp"
#include "mriq_directives.hpp"

#include "esp_templates.hpp"

const size_t MEM_SIZE = 5304320 / (DMA_WIDTH/8);

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "mriq_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    mriq_wrapper *acc;
#else
    mriq *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
    {
        // ACC
#ifdef CADENCE
        acc = new mriq_wrapper("mriq_wrapper");
#else
        acc = new mriq("mriq_wrapper");
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
        num_batch_k = 1;
        batch_size_k = 16;
        num_batch_x = 1;
        batch_size_x = 4;
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
    int32_t num_batch_k;
    int32_t batch_size_k;
    int32_t num_batch_x;
    int32_t batch_size_x;

    unsigned in_words_adj;
    unsigned out_words_adj;
    unsigned in_size;
    unsigned out_size;
    unsigned in_len;
    unsigned out_len;
    unsigned out_offset;
    unsigned mem_size;

    float *gold;
    float *out;
    float *in;

  // Other Functions

  void load_mem(float *in, int offset, int32_t base_index, int32_t size);

};

#endif // __SYSTEM_HPP__
