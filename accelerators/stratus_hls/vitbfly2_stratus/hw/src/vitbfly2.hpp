// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __VITBFLY2_HPP__
#define __VITBFLY2_HPP__

#include "vitbfly2_conf_info.hpp"
#include "vitbfly2_debug_info.hpp"

#include "esp_templates.hpp"

#include "vitbfly2_directives.hpp"

#include "utils/esp_handshake.hpp"

// Include generated header files for PLM here

class vitbfly2 : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Output <-> Input

    // Constructor
    SC_HAS_PROCESS(vitbfly2);
    vitbfly2(const sc_module_name& name)
        : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Clock binding for memories
        HLS_MAP_mm0;
        HLS_MAP_mm1;
        HLS_MAP_pp0;
        HLS_MAP_pp1;
        HLS_MAP_d_brtab27;
        HLS_MAP_symbols;
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure vitbfly2
    esp_config_proc cfg;

    // Functions
    void viterbi_butterfly2_generic(void);

    // Private local memories
    uint8_t mm0[64];
    uint8_t mm1[64];
    uint8_t pp0[64];
    uint8_t pp1[64];
    uint8_t d_brtab27[2][32];
    uint8_t symbols[64];

    // Private state variables
};


#endif /* __VITBFLY2_HPP__ */
