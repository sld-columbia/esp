/* Copyright 2017 Columbia University, SLD Group */

#ifndef __<ACCELERATOR_NAME>_HPP__
#define __<ACCELERATOR_NAME>_HPP__

#include "<accelerator_name>_conf_info.hpp"
#include "<accelerator_name>_debug_info.hpp"

#include "utils/esp_utils.hpp"
#include "utils/esp_systemc.hpp"
#include "utils/configs/esp_config_proc.hpp"

#include "core/accelerators/esp_accelerator_3P.hpp"

// Include generated header files for PLM here

class <accelerator_name> : public esp_accelerator_3P<DMA_WIDTH>
{
    public:
        // Constructor
        SC_HAS_PROCESS(<accelerator_name>);
        <accelerator_name>(const sc_module_name& name)
          : esp_accelerator_3P<DMA_WIDTH>(name)
          , cfg("config")
        {
            // Signal binding
            cfg.bind_with(*this);

	    // Clock binding for memories
        }

        // Processes

        // Load the input data
        void load_input();

        // Computation
        void compute_kernel();

        // Store the output data
        void store_output();

        // Configure <accelerator_name>
        esp_config_proc cfg;

        // Functions

        // Private local memories
#if (DMA_WIDTH == 32)

#elif (DMA_WIDTH == 64)

#endif

};


#endif /* __<ACCELERATOR_NAME>_HPP__ */
