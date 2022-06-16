// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "sensor_dma_conf_info.hpp"
#include "sensor_dma_debug_info.hpp"
#include "sensor_dma.hpp"
#include "sensor_dma_directives.hpp"

#include "esp_templates.hpp"

const size_t MEM_SIZE = 16 / (DMA_WIDTH/8);

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "sensor_dma_wrap.h"
#endif

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    sensor_dma_wrapper *acc;
#else
    sensor_dma *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
        : esp_system<DMA_WIDTH, MEM_SIZE>(name)
    {
        // ACC
#ifdef CADENCE
        acc = new sensor_dma_wrapper("sensor_dma_wrapper");
#else
        acc = new sensor_dma("sensor_dma_wrapper");
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
        rd_sp_offset = 1;
        rd_wr_enable = 0;
        wr_size = 1;
        wr_sp_offset = 1;
        rd_size = 1;
        dst_offset = 1;
        src_offset = 1;
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
    int32_t rd_sp_offset;
    int32_t rd_wr_enable;
    int32_t wr_size;
    int32_t wr_sp_offset;
    int32_t rd_size;
    int32_t dst_offset;
    int32_t src_offset;

    uint32_t in_words_adj;
    uint32_t out_words_adj;
    uint32_t in_size;
    uint32_t out_size;
    int64_t *in;
    int64_t *out;
    int64_t *gold;

    // Other Functions
};

#endif // __SYSTEM_HPP__
