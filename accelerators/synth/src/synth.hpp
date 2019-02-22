/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SYNTH_HPP__
#define __SYNTH_HPP__

#include "synth_conf_info.hpp"
#include "synth_debug_info.hpp"

#include "esp_templates.hpp"

#include "synth_directives.hpp"

// Include generated header files for PLM here
// No PLMs

// Constants
#define STREAMING 0
#define STRIDED   1
#define IRREGULAR 2

class synth : public esp_accelerator_3P<DMA_WIDTH>
{
public:

    // Constructor
    SC_HAS_PROCESS(synth);
    synth(const sc_module_name& name)
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

    // Configure synth
    esp_config_proc cfg;

    // Functions

    // Private local memories

};


#endif /* __SYNTH_HPP__ */
