// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: MIT

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "<accelerator_name>_conf_info.hpp"
#include "<accelerator_name>_debug_info.hpp"
#include "<accelerator_name>.hpp"
#include "<accelerator_name>_directives.hpp"

#include "esp_templates.hpp"

const size_t MEM_SIZE = /* Compute memory footprint */

#include "core/systems/esp_system.hpp"

#include "<accelerator_name>_wrap.h"

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

        // ACC instance
       <accelerator_name>_wrapper *acc;

        // Constructor
        SC_HAS_PROCESS(system_t);
        system_t(sc_module_name name)
          : esp_system<DMA_WIDTH, MEM_SIZE>(name)
        {
             // ACC
             acc = new <accelerator_name>_wrapper("<accelerator_name>_wrapper");

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

        // Accelerator-specific data

	// Other Functions
};

#endif // __SYSTEM_HPP__
