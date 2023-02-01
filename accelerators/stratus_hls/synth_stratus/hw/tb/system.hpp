// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__

#include "synth_conf_info.hpp"
#include "synth_debug_info.hpp"
#include "synth.hpp"
#include "synth_directives.hpp"

#include "esp_templates.hpp"

#include "core/systems/esp_system.hpp"

//#define COLLECT_LATENCY 0

#ifdef CADENCE
#include "synth_wrap.h"
#endif

const size_t MEM_SIZE = 3000000; /* Compute memory footprint */
const size_t N_ACC = 12;

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

#ifdef COLLECT_LATENCY
    put_get_channel<bool> load_chnl;
    put_get_channel<bool> compute_chnl;
    put_get_channel<bool> store_chnl;

    nb_get_initiator<bool> load;
    nb_get_initiator<bool> compute;
    nb_get_initiator<bool> store;
#endif

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
#ifdef COLLECT_LATENCY
    , load("load")
    , compute("compute")
    , store("store")
#endif
    {
#ifdef COLLECT_LATENCY
        SC_CTHREAD(report_latency, clk.pos());
        reset_signal_is(acc_rst, false);
#endif
        
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
#ifdef COLLECT_LATENCY
        acc->load(load_chnl);
        acc->compute(compute_chnl);
        acc->store(store_chnl);
        
        this->load(load_chnl);
        this->compute(compute_chnl);
        this->store(store_chnl);

        load.clk_rst(clk, rst);
        compute.clk_rst(clk, rst);
        store.clk_rst(clk, rst);
#endif
    
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
    void load_memory_acc_id(int acc_id);
    int validate_acc_id(int acc_id);

    // Dump internal memory
    void dump_memory();
    void dump_memory_acc_id(int acc_id);

    // Validate accelerator results
    int validate();
    sc_signal<int> acc_num;

#ifdef COLLECT_LATENCY
    void report_latency();
#endif

    // Accelerator-specific data
    uint32_t *in;
    uint32_t *out;

    // Other Functions

    // Variables
    conf_info_t conff;
    conf_info_t configs[N_ACC];
};

#endif // __SYSTEM_HPP__
