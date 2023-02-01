// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "<accelerator_name>_conf_info.hpp"
#include "<accelerator_name>_debug_info.hpp"
#include "<accelerator_name>.hpp"
#include "<accelerator_name>_directives.hpp"

#include "esp_templates.hpp"

const size_t MEM_SIZE = /* <<--mem-footprint-->> */ / (DMA_WIDTH/8);

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "<accelerator_name>_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    <accelerator_name>_wrapper *acc;
#else
    <accelerator_name> *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
    {
        // ACC
#ifdef CADENCE
        acc = new <accelerator_name>_wrapper("<accelerator_name>_wrapper");
#else
        acc = new <accelerator_name>("<accelerator_name>_wrapper");
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

    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t out_size;
    int/* <<--data-width-->> */_t *in;
    int/* <<--data-width-->> */_t *out;
    int/* <<--data-width-->> */_t *gold;

    // Other Functions
};

#endif // __SYSTEM_HPP__
