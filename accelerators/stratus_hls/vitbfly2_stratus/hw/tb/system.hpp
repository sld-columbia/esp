// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "vitbfly2_conf_info.hpp"
#include "vitbfly2_debug_info.hpp"
#include "vitbfly2.hpp"
#include "vitbfly2_directives.hpp"

#include "esp_templates.hpp"

const size_t MEM_SIZE = (384 * 8) / DMA_WIDTH;

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "vitbfly2_wrap.h"
#endif

    class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
    {
    public:

        // ACC instance
#ifdef CADENCE
        vitbfly2_wrapper *acc;
#else
        vitbfly2 *acc;
#endif

        // Constructor
        SC_HAS_PROCESS(system_t);
        system_t(sc_module_name name,
                 std::string in_path,
                 std::string gold_path)
            : esp_system<DMA_WIDTH, MEM_SIZE>(name)
            , input_data_path(in_path)
            , image_gold_test_path(gold_path)
        {
            // ACC
#ifdef CADENCE
            acc = new vitbfly2_wrapper("vitbfly2_wrapper");
#else
            acc = new vitbfly2("vitbfly2_wrapper");
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

        // Optionally free resources (arrays)
        // void clean_up(void);

        // Accelerator-specific data
        // uint32_t n_Invocations; // number of accelerator invocations

        // Path for the input data
        std::string input_data_path;

        // Path for the gold memory image results (output image)
        std::string image_gold_test_path;

        // For validate
        int *imgOut;

        // Other Functions
    };

#endif // __SYSTEM_HPP__
