// Copyright (c) 2011-2023 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_HPP__
#define __CONV2D_HPP__

#include <math.h>

#include "common.hpp"
#include "conv2d_data.hpp"
#include "fpdata.hpp"
#include "conv2d_conf_info.hpp"
#include "conv2d_debug_info.hpp"

#include "esp_templates.hpp"

#include "conv2d_directives.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DMA_SIZE SIZE_WORD
#define PARALLELISM 8
#define PARAL_LOG2 3

class conv2d : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(conv2d);
    conv2d(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
	, load_compute_cfg_done("load_compute_cfg_done")
	, load_store_cfg_done("load_store_cfg_done")
    {
        // Signal binding
        cfg.bind_with(*this);
	load_compute_cfg_done.bind_with<DMA_WIDTH>(*this);
	load_store_cfg_done.bind_with<DMA_WIDTH>(*this);

        // Map arrays to memories
        /* <<--plm-bind-->> */
        HLS_MAP_plm(plm_out_pong, PLM_OUT_NAME);
        HLS_MAP_plm(plm_out_ping, PLM_OUT_NAME);
        HLS_MAP_plm(plm_weights_pong, PLM_WEIGHTS_NAME);
        HLS_MAP_plm(plm_weights_ping, PLM_WEIGHTS_NAME);
        HLS_FLATTEN_ARRAY(plm_bias_pong);
        HLS_FLATTEN_ARRAY(plm_bias_ping);
        HLS_MAP_plm(plm_in_pong, PLM_IN_NAME);
        HLS_MAP_plm(plm_in_ping, PLM_IN_NAME);
        HLS_FLATTEN_ARRAY(reg_patch);
        HLS_FLATTEN_ARRAY(reg_mac);
        HLS_FLATTEN_ARRAY(reg_w);
    }

    // Processes

    // Load the input data
    void load_input();

    // Computation
    void compute_kernel();

    // Store the output data
    void store_output();

    // Configure conv2d
    esp_config_proc cfg;

    // Custom handshakes
    handshake_t load_compute_cfg_done;
    handshake_t load_store_cfg_done;

    // Functions
    void compute_dimensions(
	const uint16_t height, const uint16_t width, const uint16_t n_channels,
	const bool is_padded, const uint4_t stride, const uint4_t filter_dim,
	const uint16_t n_filters, const uint2_t pool_type, const uint16_t batch_size,
	uint16_t *output_w, uint4_t *pad,
	uint16_t *feature_size, uint16_t *filter_size, uint32_t *filters_size, 
	uint16_t *max_cacheable_rows, uint16_t *max_cacheable_rows_init,
	uint16_t *max_cacheable_size, uint16_t *max_cacheable_size_init,
	uint16_t *max_cacheable_filters, uint16_t *max_cacheable_filters_size,
	uint16_t *max_cacheable_bias_chunks, uint16_t *max_cacheable_bias_size,
	uint16_t *total_input_chunks, uint16_t *total_filters_chunks,
	uint16_t *feature_offset_incr, uint16_t *feature_offset_incr_init,
	uint16_t *channel_offset_incr, uint16_t *out_channel_offset_incr,
	uint16_t *out_channel_pool_offset_incr, uint32_t *filters_offset_start_base,
	uint32_t *bias_offset_start_base, uint32_t *feature_offset_start_base,
	uint12_t *loadable_chan, uint12_t *chan_iters, uint12_t *chan_rem,
	uint16_t *loadable_chan_sz, uint16_t *chan_rem_sz);
    void patch_extractor(
	const uint16_t channels, const uint16_t height, const uint16_t width,
	const uint16_t channel_size, const uint16_t ping_input,
	const uint16_t output_row,  const uint16_t output_col,
	const uint4_t pad, const uint4_t kernel_dim);
    void multiple_multiplier_accumulator(
    const uint16_t ping_weights, const uint16_t ping_bias, const uint16_t ping_output,
    const uint16_t filter_size, const uint16_t num_filters,
    const uint16_t filter_chunk, const uint16_t cacheable_filters, const uint16_t plm_bias_index,
    const uint16_t output_plm_offset, const uint16_t loadable_output_size,
    const bool do_relu);

    // Configuration handshakes
    inline void load_compute_cfg_handshake();
    inline void compute_load_cfg_handshake();
    inline void load_store_cfg_handshake();
    inline void store_load_cfg_handshake();

    // Private local memories
    FPDATA_WORD plm_in_ping[INPUT_PLM_SIZE];
    FPDATA_WORD plm_in_pong[INPUT_PLM_SIZE];
    FPDATA_WORD plm_weights_ping[WEIGHTS_PLM_SIZE];
    FPDATA_WORD plm_weights_pong[WEIGHTS_PLM_SIZE];
    FPDATA_WORD plm_bias_ping[BIAS_PLM_SIZE];
    FPDATA_WORD plm_bias_pong[BIAS_PLM_SIZE];
    FPDATA_WORD plm_out_ping[OUTPUT_PLM_SIZE];
    FPDATA_WORD plm_out_pong[OUTPUT_PLM_SIZE];
    FPDATA      reg_patch[PARALLELISM];
    FPDATA      reg_mac[PARALLELISM];
    FPDATA      reg_w[PARALLELISM];

    // Custom configuration signals
    sc_signal<uint4_t> pad_sig;
    sc_signal<uint16_t> output_w_sig;
    sc_signal<uint16_t> filter_size_sig;
    sc_signal<uint16_t> total_filters_chunks_sig;
    sc_signal<uint16_t> total_input_chunks_sig;
    sc_signal<uint16_t> max_cacheable_rows_sig;
    sc_signal<uint16_t> max_cacheable_rows_init_sig;
    sc_signal<uint16_t> max_cacheable_filters_sig;
    sc_signal<uint16_t> max_cacheable_bias_chunks_sig;
    sc_signal<uint16_t> out_channel_offset_incr_sig;
    sc_signal<uint16_t> out_channel_pool_offset_incr_sig;
    sc_signal<uint32_t> feature_offset_start_base_sig;
    sc_signal<uint12_t> loadable_chan_sig;
    sc_signal<uint12_t> chan_iters_sig;
    sc_signal<uint12_t> chan_rem_sig;
    sc_signal<uint16_t> loadable_chan_sz_sig;
    sc_signal<uint16_t> chan_rem_sz_sig;
};


#endif /* __CONV2D_HPP__ */
