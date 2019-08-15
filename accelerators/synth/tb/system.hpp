// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "synth_conf_info.hpp"
#include "synth_debug_info.hpp"
#include "synth.hpp"
#include "synth_directives.hpp"

#include "esp_templates.hpp"

#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "synth_wrap.h"
#endif

const size_t MEM_SIZE = 3000000; /* Compute memory footprint */
const size_t N_ACC = 12;

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    synth_wrapper *acc;
#else
    synth *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
	: esp_system<DMA_WIDTH, MEM_SIZE>(name)
	{
	    // ACC
#ifdef CADENCE
	    acc = new synth_wrapper("synth_wrapper");
#else
	    acc = new synth("synth_wrapper");
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

    // Init all the accelerator's parameters
    void init_acc_params();

    // Load internal memory
    void load_memory();

    // Send configuration
    void send_config(int acc_id);

    // Dump internal memory
    void dump_memory();

    // Validate accelerator results
    int validate();

    // Accelerator-specific data
    

    // Other Functions

    // Variables
    conf_info_t conff;
    conf_info_t configs[N_ACC];
};

#endif // __SYSTEM_HPP__
