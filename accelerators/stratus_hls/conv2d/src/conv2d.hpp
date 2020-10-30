// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#ifndef __CONV2D_HPP__
#define __CONV2D_HPP__

#include <math.h>

#include "conv2d_data.hpp"
#include "fpdata.hpp"
#include "common.hpp"
#include "conv2d_conf_info.hpp"
#include "conv2d_debug_info.hpp"

#include "esp_templates.hpp"

#include "conv2d_directives.hpp"

#define __round_mask(x, y) ((y)-1)
#define round_up(x, y) ((((x)-1) | __round_mask(x, y))+1)
/* <<--defines-->> */
#define DMA_SIZE SIZE_WORD

class conv2d : public esp_accelerator_3P<DMA_WIDTH>
{
public:
    // Constructor
    SC_HAS_PROCESS(conv2d);
    conv2d(const sc_module_name& name)
    : esp_accelerator_3P<DMA_WIDTH>(name)
        , cfg("config")
    {
        // Signal binding
        cfg.bind_with(*this);

        // Map arrays to memories
        /* <<--plm-bind-->> */
        HLS_MAP_plm(plm_out_pong, PLM_OUT_NAME);
        HLS_MAP_plm(plm_out_ping, PLM_OUT_NAME);
        HLS_MAP_plm(plm_weights_pong, PLM_WEIGHTS_NAME);
        HLS_MAP_plm(plm_weights_ping, PLM_WEIGHTS_NAME);
        HLS_MAP_plm(plm_in_pong, PLM_IN_NAME);
        HLS_MAP_plm(plm_in_ping, PLM_IN_NAME);
        HLS_MAP_plm(plm_patch, PLM_PATCH_NAME);
        HLS_MAP_plm(plm_mac, PLM_MAC_NAME);
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

    // Functions
    void compute_dimensions(uint16_t height, uint16_t width, uint16_t channels, uint8_t pad_h,
			    uint8_t pad_w, uint8_t stride_h, uint8_t stride_w, uint8_t dilation_h,
			    uint8_t dilation_w, uint8_t filter_height, uint8_t filter_width,
			    uint16_t num_filters, uint16_t *output_h, uint16_t *output_w,
			    uint16_t *filter_size, uint16_t *max_cacheable_rows, uint16_t *max_cacheable_size,
			    uint16_t *max_cacheable_filters, uint16_t *total_input_chunks,
			    uint16_t *total_filters_chunks);
    void patch_extractor(const uint16_t channels, const uint16_t height, const uint16_t width,
			 const uint16_t channel_size, const uint16_t ping_input,
			 const uint16_t output_row,  const uint16_t output_col,
			 const uint16_t pad_h, const uint16_t pad_w,
			 const uint16_t dilation_h, const uint16_t dilation_w,
			 const uint16_t kernel_h, const uint16_t kernel_w);
    void multiple_multiplier_accumulator(const uint16_t ping_weights, const uint16_t ping_output,
					 const uint16_t filter_size, const uint16_t num_filters,
					 const uint16_t filter_chunk,
					 const uint16_t max_cacheable_filters,
					 const uint16_t output_plm_offset,
					 const uint16_t loadable_output_size);

    // Private local memories
    FPDATA_WORD plm_in_ping[INPUT_PLM_SIZE];
    FPDATA_WORD plm_in_pong[INPUT_PLM_SIZE];
    FPDATA_WORD plm_weights_ping[WEIGHTS_PLM_SIZE];
    FPDATA_WORD plm_weights_pong[WEIGHTS_PLM_SIZE];
    FPDATA_WORD plm_out_ping[OUTPUT_PLM_SIZE];
    FPDATA_WORD plm_out_pong[OUTPUT_PLM_SIZE];
    FPDATA_WORD plm_patch[PATCH_PLM_SIZE];
    FPDATA_WORD plm_mac[MAC_PLM_SIZE];
};


#endif /* __CONV2D_HPP__ */
