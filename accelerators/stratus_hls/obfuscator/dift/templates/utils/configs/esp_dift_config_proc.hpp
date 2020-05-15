/* Copyright 2018 Columbia University, SLD Group */

#ifndef __ESP_DIFT_CONFIG_PROC_HPP__
#define __ESP_DIFT_CONFIG_PROC_HPP__

#include "esp_dift_config.hpp"

class esp_dift_config_proc : public esp_dift_config
{
    // Inline module
    HLS_INLINE_MODULE;

    public:

        // -- Internal signals

        // Process synchronization
        sc_signal<bool> done;

        // -- Module constructor

        SC_HAS_PROCESS(esp_dift_config_proc);
        esp_dift_config_proc(const sc_module_name& name)
          : esp_dift_config(name)
          , done("done")
        {
            // Nothing to do
        }

        // -- Processes

        // Configure the wrapper
        void config_wrapper();

        // -- Functions

        // Call to wait for configuration
        inline void wait_for_config();
};

// Implementation
#include "esp_dift_config_proc.i.hpp"

#endif // __ESP_DIFT_CONFIG_PROC_HPP__
