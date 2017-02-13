/* Copyright 2017 Columbia University, SLD Group */

#ifndef __SORT_HPP__
#define __SORT_HPP__

#include "sort_conf_info.hpp"
#include "sort_debug_info.hpp"

#include "utils/esp_utils.hpp"
#include "utils/esp_systemc.hpp"
#include "utils/configs/esp_config_proc.hpp"

#include "core/accelerators/esp_accelerator_3P.hpp"

#include "sort_plm_block.hpp"

// Local memory size: number of elements
#define lgLEN 10
#define LEN (1<<lgLEN)
// Number of comparators per computational chain
#define lgNUM 5
#define NUM (1<<lgNUM)

template <
  size_t DMA_WIDTH // width of the DMA channel in num of bits
>
class sort : public esp_accelerator_3P<DMA_WIDTH>
{
    public:

        // Computation <-> Computation

        // Ack and req channel
        handshake_t compute_2_ready;

        // Req channel binding
        handshake_req_t compute_2_ready_req;

        // Ack channel binding
        handshake_ack_t compute_2_ready_ack;

        // Constructor
        SC_HAS_PROCESS(sort);
        sort(const sc_module_name& name)
          : esp_accelerator_3P<DMA_WIDTH>(name)
          , cfg("config")
	  , compute_2_ready("compute_2_ready")
          , compute_2_ready_req("compute_2_ready_req")
          , compute_2_ready_ack("compute_2_ready_ack")
        {
            // Signal binding
            cfg.bind_with(*this);

            SC_CTHREAD(compute_2_kernel, this->clk.pos());
            reset_signal_is(this->rst, false);
            // set_stack_size(0x400000);

            // Clock and reset binding
            compute_2_ready_req.clk_rst(this->clk, this->rst);
            compute_2_ready_ack.clk_rst(this->clk, this->rst);

            // Request and ack binding
            compute_2_ready_req(compute_2_ready);
            compute_2_ready_ack(compute_2_ready);

	    // Clock binding for memories
	    A0.clk(this->clk);
	    A1.clk(this->clk);
	    C0.clk(this->clk);
	    C1.clk(this->clk);
	    B0.clk(this->clk);
	    B1.clk(this->clk);
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
	sort_plm_block_t<uint32_t, LEN> A0;
	sort_plm_block_t<uint32_t, LEN> A1;

	sort_plm_block_t<uint32_t, ((LEN / NUM) * NUM)> C0;
	sort_plm_block_t<uint32_t, ((LEN / NUM) * NUM)> C1;

	sort_plm_block_t<uint32_t, LEN> B0;
	sort_plm_block_t<uint32_t, LEN> B1;

};

template <
    size_t DMA_WIDTH
>
inline void sort<DMA_WIDTH>::reset_compute_1_kernel()
{
    this->input_ready_ack.reset_ack();
    this->compute_2_ready_req.reset_req();
}

template <
    size_t DMA_WIDTH
>
inline void sort<DMA_WIDTH>::reset_compute_2_kernel()
{
    this->compute_2_ready_ack.reset_ack();
    this->output_ready_req.reset_req();
}

template <
    size_t DMA_WIDTH
>
inline void sort<DMA_WIDTH>::compute_compute_2_handshake()
{
	HLS_DEFINE_PROTOCOL("compute-compute_2-handshake");

	this->compute_2_ready_req.req();
}

template <
	size_t DMA_WIDTH
	>
inline void sort<DMA_WIDTH>::compute_2_compute_handshake()
{
	HLS_DEFINE_PROTOCOL("compute_2-compute-handshake");

	this->compute_2_ready_ack.ack();
}


#endif /* __SORT_HPP__ */
