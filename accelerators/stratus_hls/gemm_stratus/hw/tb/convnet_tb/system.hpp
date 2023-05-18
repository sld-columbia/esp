// Copyright (c) 2011-2020 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __SYSTEM_HPP__
#define __SYSTEM_HPP__


#include "double_matrix_t.h"
#include "gemm_data.hpp"
#include "fpdata.hpp"
#include "gemm_conf_info.hpp"
#include "gemm_debug_info.hpp"
#include "gemm.hpp"
#include "gemm_directives.hpp"
#include "esp_templates.hpp"
#include "core/systems/esp_system.hpp"

#ifdef CADENCE
#include "gemm_wrap.h"
#endif


// Testbench constants
#define VERBOSE 1

#define N_CONV_LAYERS 4
#define N_FC_LAYERS 1

// Decomment to activate feature

const size_t MEM_SIZE = 50000000;

class system_t : public esp_system<DMA_WIDTH, MEM_SIZE>
{
public:

    // ACC instance
#ifdef CADENCE
    gemm_wrapper *acc;
#else
    gemm *acc;
#endif

    // Constructor
    SC_HAS_PROCESS(system_t);
    system_t(sc_module_name name)
	: esp_system<DMA_WIDTH, MEM_SIZE>(name)
        {
	    // ACC
#ifdef CADENCE
	    acc = new gemm_wrapper("gemm_wrapper");
#else
	    acc = new gemm("gemm_wrapper");
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

    void run_pv(int layer, bool fully_connected = false);

    void setup_memory(int target_layer, bool fully_connected);

    // Accelerator-specific data
    unsigned batch_size;
    unsigned is_transposed;
    unsigned rowsA;
    unsigned colsA;
    unsigned rowsB;
    unsigned colsB;
    unsigned rowsB_actual;
    unsigned colsB_actual;
    unsigned size_inA;
    unsigned size_inB;
    unsigned size_out;

    // Mem index
    uint32_t indexA;
    uint32_t indexB;

    // Input matrix 1
    double_matrix_t * matrix_inA;

    // Input matrix 2
    double_matrix_t * matrix_inB;

    // Output matrix (acc)
    double_matrix_t * matrix_out;

    // Output matrix (pvc)
    double_matrix_t * matrix_out_gold;

	float* image;
	float* dummy_b;

	float **w_conv;
	float **w_skip;
	float **w_fc;

	float **out_conv;
	float **out_skip;

	float** out_fc;

	//Network description

	//Convolutional layers

	int32_t chans_c      [N_CONV_LAYERS] = { 3, 16,  32,  64};
	int32_t height_c     [N_CONV_LAYERS] = { 32, 32, 16, 8};
	int32_t width_c      [N_CONV_LAYERS] = { 32, 32, 16, 8};
	int32_t n_flt_c      [N_CONV_LAYERS] = { 16, 32, 64, 128};
	int32_t flt_dim_c    [N_CONV_LAYERS] = { 3, 3, 3, 3};
	int32_t pad_c        [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t stride_c     [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t dil_c        [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t relu_c       [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t pool_c       [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t batch_sz_c   [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t batch_norm_c [N_CONV_LAYERS] = { 1, 1, 1, 1};
	int32_t pool_out_c   [N_CONV_LAYERS] = { 0, 1, 1, 3};// stands for pool after batchnorm


	// 1=2x2 max
	// 2=2x2 average
	// 3=8x8

	//Skip layers (1st layer does not exist)

	int32_t chans_s      [N_CONV_LAYERS] = { 0, 16,  32,  64};
	int32_t height_s     [N_CONV_LAYERS] = { 0, 32, 16, 8};
	int32_t width_s      [N_CONV_LAYERS] = { 0, 32, 16, 8};
	int32_t n_flt_s      [N_CONV_LAYERS] = { 0, 32, 64, 128};
	int32_t flt_dim_s    [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t pad_s        [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t stride_s     [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t dil_s        [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t relu_s       [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t pool_s       [N_CONV_LAYERS] = { 0, 0, 0, 0};
	int32_t batch_sz_s   [N_CONV_LAYERS] = { 0, 1, 1, 1};
	int32_t batch_norm_s [N_CONV_LAYERS] = { 0, 0, 0, 0};

	//Fully connected layers

	int32_t relu_fc      [N_FC_LAYERS] = { 0 } ;
	int32_t soft         [N_FC_LAYERS] = { 1 } ;
	int32_t transpose    [N_FC_LAYERS] = { 1 };
	int32_t ninputs      [N_FC_LAYERS] = { 1 };
	int32_t d3           [N_FC_LAYERS] = { 1 };
	int32_t d2           [N_FC_LAYERS] = { 128};
	int32_t d1           [N_FC_LAYERS] = { 2 } ;


    // Other Functions
};

#endif // __SYSTEM_HPP__
