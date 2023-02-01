// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __DUMMY_HPP__
#define __DUMMY_HPP__

#include "dummy_conf_info.hpp"
#include "dummy_debug_info.hpp"

#include "esp_templates.hpp"

#include "dummy_directives.hpp"

#define PLM_SIZE 512

class dummy : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(dummy);
    dummy(const sc_module_name& name)
        : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        HLS_MAP_plm(plm0);
        HLS_MAP_plm(plm1);
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure dummy
    esp_config_proc cfg;

    // Functions

    // Private local memories
    uint64_t plm0[PLM_SIZE];
    uint64_t plm1[PLM_SIZE];

};

#endif /* __DUMMY_HPP__ */
