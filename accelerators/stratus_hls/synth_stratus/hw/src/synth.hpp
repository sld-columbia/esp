// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYNTH_HPP__
#define __SYNTH_HPP__

#include "synth_conf_info.hpp"
#include "synth_debug_info.hpp"

#include "esp_templates.hpp"

#include "synth_directives.hpp"

// Include generated header files for PLM here
// No PLMs
//#define COLLECT_LATENCY 1

// Constants
#define STREAMING 0
#define STRIDED   1
#define IRREGULAR 2

class synth : public esp_accelerator_3P<DMA_WIDTH>
{
public:

#ifdef COLLECT_LATENCY
    nb_put_initiator<bool> load;
    nb_put_initiator<bool> compute;
    nb_put_initiator<bool> store;
#endif
    // Constructor
    SC_HAS_PROCESS(synth);
    synth(const sc_module_name& name)
	: esp_accelerator_3P<DMA_WIDTH>(name)
	, cfg("config")
#ifdef COLLECT_LATENCY
    , load("load")
    , compute("compute")
    , store("store")
#endif
        {     
#ifdef COLLECT_LATENCY
            SC_CTHREAD(latency_collector, this->clk.pos());
            this->reset_signal_is(this->rst, false);
#endif
            // Signal binding
#ifdef COLLECT_LATENCY
            load.clk_rst(clk, rst);
            compute.clk_rst(clk, rst);
            store.clk_rst(clk, rst);
#endif
            cfg.bind_with(*this);
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

    //channel for transferring errors between loads and stores
    sc_signal<uint32_t> rd_errs;
   
#ifdef COLLECT_LATENCY
    //Latency collector
    void latency_collector();
    
    // signals
    sc_signal<bool> sig_load;
    sc_signal<bool> sig_compute;
    sc_signal<bool> sig_store;
#endif

    // Functions

    // Private local memories

};


#endif /* __SYNTH_HPP__ */
