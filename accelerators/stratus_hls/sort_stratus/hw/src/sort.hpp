// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SORT_HPP__
#define __SORT_HPP__

#include "sort_conf_info.hpp"
#include "sort_debug_info.hpp"

#include "esp_templates.hpp"

#include "sort_directives.hpp"

class sort : public esp_accelerator_3P<DMA_WIDTH>
{
    public:

        // Computation <-> Computation

        // Ack and req channel
        handshake_t compute_2_ready;

        // Constructor
        SC_HAS_PROCESS(sort);
        sort(const sc_module_name& name)
          : esp_accelerator_3P<DMA_WIDTH>(name)
          , cfg("config")
	  , compute_2_ready("compute_2_ready")
        {
            // Signal binding
            cfg.bind_with(*this);

            SC_CTHREAD(compute_2_kernel, this->clk.pos());
            reset_signal_is(this->rst, false);
            // set_stack_size(0x400000);

            // Clock and reset binding for additional handshake
            compute_2_ready.bind_with(*this);

	    // Binding for memories
	    HLS_MAP_A0;
	    HLS_MAP_A1;
	    HLS_MAP_B0;
	    HLS_MAP_B1;
	    HLS_MAP_C0;
	    HLS_MAP_C1;
        }

        // Processes

        // Load the input data
        void load_input();

        // Realize the computation
        void compute_kernel();
        void compute_2_kernel();

        // Store the output data
        void store_output();

        // Configure sort
        esp_config_proc cfg;

        // Functions

        // Reset first compute_kernel channels
        inline void reset_compute_1_kernel();

        // Reset second compute_kernel channels
        inline void reset_compute_2_kernel();

        // Handshake callable by compute_kernel
        inline void compute_compute_2_handshake();

        // Handshake callable by store_output
        inline void compute_2_compute_handshake();

        // Private local memories
	uint32_t A0[LEN];
	uint32_t A1[LEN];

	uint32_t B0[LEN];
	uint32_t B1[LEN];
	uint32_t C0[LEN / NUM][NUM];
	uint32_t C1[LEN / NUM][NUM];
};

inline void sort::reset_compute_1_kernel()
{
    this->input_ready.ack.reset_ack();
    this->compute_2_ready.req.reset_req();
}

inline void sort::reset_compute_2_kernel()
{
    this->compute_2_ready.ack.reset_ack();
    this->output_ready.req.reset_req();
}

inline void sort::compute_compute_2_handshake()
{
	HLS_DEFINE_PROTOCOL("compute-compute_2-handshake");

	this->compute_2_ready.req.req();
}

inline void sort::compute_2_compute_handshake()
{
	HLS_DEFINE_PROTOCOL("compute_2-compute-handshake");

	this->compute_2_ready.ack.ack();
}


#endif /* __SORT_HPP__ */
