// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SENSOR_DMA_HPP__
#define __SENSOR_DMA_HPP__

#include "sensor_dma_conf_info.hpp"
#include "sensor_dma_debug_info.hpp"

#include "esp_templates.hpp"

#include "sensor_dma_directives.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DATA_WIDTH 64
#define DMA_SIZE SIZE_DWORD
#define PLM_IN_WORD 12 * 1024

class sensor_dma : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(sensor_dma);
    sensor_dma(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Map arrays to memories
        /* <<--plm-bind-->> */
        HLS_MAP_plm(plm, PLM_OUT_NAME);
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure sensor_dma
    esp_config_proc cfg;

    // Functions

    // Private local memories
    sc_dt::sc_int<DATA_WIDTH> plm[PLM_IN_WORD];

};


#endif /* __SENSOR_DMA_HPP__ */
