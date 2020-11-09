// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "conv2d.hpp"
#include "conv2d_directives.hpp"

// Functions

#include "conv2d_functions.hpp"

// Processes

// TODO
// - DMA 64 bits cannot do DMA with 32 bit alignment
// - size of PLMs may affect others, output that fits may affect how many filters to load
// - we used uint16_t for all unsigned numbers, for some we may need more bits! make sure
//   of that and add asserts

void conv2d::load_input()
{

    // Reset
    {
        HLS_PROTO("load-reset");

        this->reset_load_input();
	load_compute_cfg_done.req.reset_req();
	load_store_cfg_done.req.reset_req();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    uint16_t n_channels;
    uint16_t n_filters;
    uint4_t filter_dim;
    uint4_t stride;
    bool is_padded;
    uint16_t height;
    uint16_t width;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_dim = config.filter_dim;
        stride = config.stride;
        is_padded = config.is_padded;
        height = config.feature_map_height;
        width = config.feature_map_width;
    }

    // Precompute sizes
    bool ping_input = true;
    bool ping_weights = true;
    bool ping_bias = true;
    uint4_t pad;
    uint16_t output_w;
    uint16_t feature_size;
    uint16_t filter_size;
    uint32_t filters_size;
    uint16_t max_cacheable_rows;
    uint16_t max_cacheable_size;
    uint16_t max_cacheable_filters;
    uint16_t max_cacheable_filters_size;
    uint16_t max_cacheable_bias_chunks;
    uint16_t max_cacheable_bias_size;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    uint16_t feature_offset_incr;
    uint16_t channel_offset_incr;
    uint32_t filters_offset_start_base;
    uint32_t feature_offset_start_base;
    uint32_t bias_offset_start_base;

    compute_dimensions(height, width, n_channels, (bool) is_padded,
		       stride, (uint8_t) filter_dim, n_filters,
		       &output_w, &pad, &feature_size, &filter_size, &filters_size,
		       &max_cacheable_rows, &max_cacheable_size, &max_cacheable_filters,
		       &max_cacheable_filters_size, &max_cacheable_bias_chunks,
		       &max_cacheable_bias_size, &total_input_chunks, &total_filters_chunks,
		       &feature_offset_incr, &channel_offset_incr, &filters_offset_start_base,
		       &bias_offset_start_base, &feature_offset_start_base);

    {
	HLS_DEFINE_PROTOCOL("load-config-sig");
	pad_sig.write(pad);
	output_w_sig.write(output_w);
	filter_size_sig.write(filter_size);
	total_filters_chunks_sig.write(total_filters_chunks);
	total_input_chunks_sig.write(total_input_chunks);
	max_cacheable_rows_sig.write(max_cacheable_rows);
	max_cacheable_filters_sig.write(max_cacheable_filters);
	max_cacheable_bias_chunks_sig.write(max_cacheable_bias_chunks);
	channel_offset_incr_sig.write(channel_offset_incr);
	feature_offset_start_base_sig.write(feature_offset_start_base);
	wait();
    }

    load_compute_cfg_handshake();
    load_store_cfg_handshake();

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

#ifndef STRATUS_HLS
	ESP_REPORT_INFO("output_w %u", output_w);
	ESP_REPORT_INFO("pad %u", (uint32_t) pad);
	ESP_REPORT_INFO("feature_size %u", feature_size);
	ESP_REPORT_INFO("filter_size %u", filter_size);
	ESP_REPORT_INFO("filters_size %u", filters_size);
	ESP_REPORT_INFO("max_cacheable_rows %u", max_cacheable_rows);
	ESP_REPORT_INFO("max_cacheable_size %u", max_cacheable_size);
	ESP_REPORT_INFO("max_cacheable_filters %u", max_cacheable_filters);
	ESP_REPORT_INFO("max_cacheable_filters_size %u", max_cacheable_filters_size);
	ESP_REPORT_INFO("max_cacheable_bias_chunks %u", max_cacheable_bias_chunks);
	ESP_REPORT_INFO("max_cacheable_bias_size %u", max_cacheable_bias_size);
	ESP_REPORT_INFO("total_input_chunks %u", total_input_chunks);
	ESP_REPORT_INFO("total_filters_chunks %u", total_filters_chunks);
	ESP_REPORT_INFO("feature_offset_incr %u", feature_offset_incr);
	ESP_REPORT_INFO("channel_offset_incr %u", channel_offset_incr);
	ESP_REPORT_INFO("filters_offset_start_base %u", filters_offset_start_base);
	ESP_REPORT_INFO("bias_offset_start_base %u", bias_offset_start_base);
	ESP_REPORT_INFO("feature_offset_start_base %u", feature_offset_start_base);
#endif
        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();

            // Chunking
	    bool single_chunk_done = false;
	    uint32_t filters_offset_start_phys = filters_offset_start_base;
	    uint32_t filters_offset_start_virt = 0;
	    uint32_t bias_offset_start_phys = bias_offset_start_base;
	    uint32_t bias_offset_start_virt = 0;
	    uint16_t bias_chunk = 0;
	    uint16_t plm_bias_index = 0;
	    for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	    {
		uint16_t plm_weights_index = 0;
		uint16_t n_words_to_load = min(filters_size - filters_offset_start_virt,
					       max_cacheable_filters_size);

		dma_info_t dma_info(filters_offset_start_phys >> DMA_WORD_PER_BEAT_LOG2,
				    n_words_to_load >> DMA_WORD_PER_BEAT_LOG2, DMA_SIZE);

		// ESP_REPORT_INFO("load_input load filters dma_info. offset: %u len %u",
		// 		filters_offset_start_phys, n_words_to_load);

		this->dma_read_ctrl.put(dma_info);

		for (uint16_t i = 0; i < n_words_to_load; i += DMA_WORD_PER_BEAT)
		{
		    HLS_BREAK_DEP(plm_weights_ping);
		    HLS_BREAK_DEP(plm_weights_pong);

		    sc_dt::sc_bv<DMA_WIDTH> dataBv;

		    dataBv = this->dma_read_chnl.get();
		    wait();

		    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
		    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
		    {
			HLS_UNROLL_SIMPLE;

			// ESP_REPORT_INFO("load_input load filters. i %u fchunk %u",
			// 		i, filter_chunk);

			if (ping_weights)
			    plm_weights_ping[plm_weights_index++] =
				dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
			else
			    plm_weights_pong[plm_weights_index++] =
				dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

			wait();
			// ESP_REPORT_INFO("dut load weight %u : %f", i, (float) INT2FP(dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64()));
		    }
		}

		filters_offset_start_phys += n_words_to_load;
		filters_offset_start_virt += n_words_to_load;

		ping_weights = !ping_weights;

		if (!bias_chunk) {
		    uint16_t n_words_to_load = min(n_filters - bias_offset_start_virt,
						   max_cacheable_bias_size);
		    dma_info_t dma_info(bias_offset_start_phys >> DMA_WORD_PER_BEAT_LOG2,
					n_words_to_load >> DMA_WORD_PER_BEAT_LOG2, DMA_SIZE);

		    // ESP_REPORT_INFO("load_input load bias dma_info. offset: %u len %u",
		    // 		bias_offset_start_phys, n_words_to_load);

		    this->dma_read_ctrl.put(dma_info);

		    for (uint16_t i = 0; i < n_words_to_load; i += DMA_WORD_PER_BEAT)
		    {
			HLS_BREAK_DEP(plm_bias_ping);
			HLS_BREAK_DEP(plm_bias_pong);

			sc_dt::sc_bv<DMA_WIDTH> dataBv;

			dataBv = this->dma_read_chnl.get();
			wait();

			// Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
			for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
			{
			    HLS_UNROLL_SIMPLE;

			    // ESP_REPORT_INFO("load_input load bias. i %u bchunk %u fchunk %u",
			    // 		    i, bias_chunk, filter_chunk);

			    if (ping_bias)
				plm_bias_ping[plm_bias_index++] =
				    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
			    else
				plm_bias_pong[plm_bias_index++] =
				    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

			    wait();
			    // ESP_REPORT_INFO("dut load weight %u : %f", i, (float) INT2FP(dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64()));
			}
		    }

		    bias_offset_start_phys += n_words_to_load;
		    bias_offset_start_virt += n_words_to_load;
		}

		bias_chunk++;
		if (bias_chunk == max_cacheable_bias_chunks) {
		    bias_chunk = 0;
		    ping_bias = !ping_bias;
		    plm_bias_index = 0;
		}

		uint16_t feature_offset_start = 0;

		for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
		{
		    uint32_t channel_offset = 0;
		    uint16_t plm_in_index = 0;

		    if (single_chunk_done) {
			this->load_compute_handshake();
			break;
		    }

		    if (total_input_chunks == 1)
			single_chunk_done = true;

		    for (uint16_t ch = 0; ch < n_channels; ch++)
		    {
			wait();

			// Configure DMA transaction
			uint16_t n_words_to_load = min(feature_size - feature_offset_start,
						       max_cacheable_size);
			uint32_t offset_start = channel_offset + feature_offset_start;
			dma_info_t dma_info(offset_start >> DMA_WORD_PER_BEAT_LOG2,
					    n_words_to_load >> DMA_WORD_PER_BEAT_LOG2, DMA_SIZE);

			// ESP_REPORT_INFO("load_input load features dma_info. offset: %u len %u",
			// 		offset_start, n_words_to_load);

			this->dma_read_ctrl.put(dma_info);

			for (uint16_t i = 0; i < n_words_to_load; i += DMA_WORD_PER_BEAT)
			{
			    HLS_BREAK_DEP(plm_in_ping);
			    HLS_BREAK_DEP(plm_in_pong);

			    sc_dt::sc_bv<DMA_WIDTH> dataBv;

			    dataBv = this->dma_read_chnl.get();
			    wait();

			    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
			    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
			    {
				HLS_UNROLL_SIMPLE;

				// ESP_REPORT_INFO("load_input most inner loop. i %u ch %u ichunk %u",
				// 		i, ch, input_chunk);

				if (ping_input)
				    plm_in_ping[plm_in_index++] =
					dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
				else
				    plm_in_pong[plm_in_index++] =
					dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();

			// ESP_REPORT_INFO("dut load feature %u : %f", i, (float) INT2FP(dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64()));

				wait();
			    }
			}

			channel_offset += channel_offset_incr;
		    }

		    ping_input = !ping_input;
		    feature_offset_start += feature_offset_incr;

		    this->load_compute_handshake();
		}
	    }
	}
    }

    // Conclude
    {
        this->process_done();
    }
}



void conv2d::store_output()
{
    // Reset
    {
        HLS_PROTO("store-reset");

        this->reset_store_output();
	load_store_cfg_done.ack.reset_ack();
        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    uint16_t n_filters;
    uint4_t filter_dim;
    uint4_t stride;
    uint16_t height;

    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_filters = config.n_filters;
        filter_dim = config.filter_dim;
        stride = config.stride;
        height = config.feature_map_height;
    }

    store_load_cfg_handshake();

    uint4_t pad;
    uint16_t output_w;
    uint16_t max_cacheable_rows;
    uint16_t max_cacheable_filters;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    uint16_t channel_offset_incr;
    uint32_t feature_offset_start_base;

    {
	HLS_DEFINE_PROTOCOL("store-config-sig");
	pad = pad_sig.read();
	output_w = output_w_sig.read();
	total_filters_chunks = total_filters_chunks_sig.read();
	total_input_chunks = total_input_chunks_sig.read();
	max_cacheable_rows = max_cacheable_rows_sig.read();
	max_cacheable_filters = max_cacheable_filters_sig.read();
	channel_offset_incr = channel_offset_incr_sig.read();
	feature_offset_start_base = feature_offset_start_base_sig.read();
	wait();
    }

    bool ping_output = true;

    // Store
    {
        HLS_PROTO("store-dma");
        wait();

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();

	    uint32_t channel_offset_base = 0;
	    for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	    {
		wait();

		uint32_t feature_offset_start_phys = feature_offset_start_base;
		uint32_t feature_offset_start_virt = 0;
		for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
		{
		    bool no_first_row = (input_chunk != 0);
		    bool no_last_row = (input_chunk != total_input_chunks - 1);
		    uint16_t first_row_to_load = (max_cacheable_rows - 2) * input_chunk;
		    uint16_t loadable_rows = min(height - first_row_to_load,
						 max_cacheable_rows);
		    uint16_t rows_to_load = loadable_rows - no_first_row - no_last_row;
		    uint16_t n_words_to_store = rows_to_load * output_w;

		    uint16_t plm_out_index = 0;
		    uint16_t cached_filters = min(max_cacheable_filters,
						  n_filters - filter_chunk * max_cacheable_filters);

		    uint32_t channel_offset = channel_offset_base;

		    this->store_compute_handshake();

		    for (uint16_t filter_i = 0; filter_i < cached_filters; filter_i++) {

			uint32_t offset_start = channel_offset + feature_offset_start_phys;
	
			dma_info_t dma_info(offset_start >> DMA_WORD_PER_BEAT_LOG2,
					    n_words_to_store >> DMA_WORD_PER_BEAT_LOG2, DMA_SIZE);

			// ESP_REPORT_INFO("store dma info. offset: %u len %u",
			// 		offset_start, n_words_to_store);

			this->dma_write_ctrl.put(dma_info);

			for (uint16_t i = 0; i < n_words_to_store; i += DMA_WORD_PER_BEAT)
			{
			    HLS_BREAK_DEP(plm_out_ping);
			    HLS_BREAK_DEP(plm_out_pong);

			    wait();

			    sc_dt::sc_bv<DMA_WIDTH> dataBv;

			    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
			    for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
			    {
				HLS_UNROLL_SIMPLE;

				if (ping_output) {
				    // ESP_REPORT_INFO("store_output most inner loop ping: %d", (int) plm_out_ping[plm_out_index]);
				    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) =
					plm_out_ping[plm_out_index++];
				} else {
				    // ESP_REPORT_INFO("store_output most inner loop pong: %d", (int) plm_out_pong[plm_out_index]);
				    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) =
					plm_out_pong[plm_out_index++];
				}
				wait();
			    }
			    this->dma_write_chnl.put(dataBv);
			}

			channel_offset += channel_offset_incr;
		    }
		    ping_output = !ping_output;
		    feature_offset_start_phys += n_words_to_store;
		    feature_offset_start_virt += n_words_to_store;
		}
		channel_offset_base += (channel_offset_incr * max_cacheable_filters);
	    }
	}
    }         

    // Conclude
    {
        this->accelerator_done();
        this->process_done();
    }
}


void conv2d::compute_kernel()
{
    // Reset
    {
        HLS_PROTO("compute-reset");

        this->reset_compute_kernel();
	load_compute_cfg_done.ack.reset_ack();

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    uint16_t n_channels;
    uint16_t n_filters;
    uint4_t filter_dim;
    uint4_t stride;
    uint16_t height;
    uint16_t width;
    bool do_relu;

    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_dim = config.filter_dim;
        stride = config.stride;
        height = config.feature_map_height;
        width = config.feature_map_width;
	do_relu = config.do_relu;
    }

    compute_load_cfg_handshake();

    uint4_t pad;
    uint16_t output_w;
    uint16_t filter_size;
    uint16_t max_cacheable_rows;
    uint16_t max_cacheable_filters;
    uint16_t max_cacheable_bias_chunks;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;

    {
	HLS_DEFINE_PROTOCOL("compute-config-sig");
	pad = pad_sig.read();
	output_w = output_w_sig.read();
	filter_size = filter_size_sig.read();
	total_filters_chunks = total_filters_chunks_sig.read();
	total_input_chunks = total_input_chunks_sig.read();
	max_cacheable_rows = max_cacheable_rows_sig.read();
	max_cacheable_filters = max_cacheable_filters_sig.read();
	max_cacheable_bias_chunks = max_cacheable_bias_chunks_sig.read();
	wait();
    }

    // Compute
    bool ping_input = true;
    bool ping_weights = true;
    bool ping_bias = true;
    bool ping_output = true;

    for (uint16_t b = 0; b < 1; b++)
    {
	wait();
	
	uint16_t bias_chunk = 0;
	uint16_t plm_bias_index = 0;
	for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	{
	    uint16_t loadable_filters = min(n_filters - filter_chunk * max_cacheable_filters,
					    max_cacheable_filters);
	    for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
	    {
		this->compute_load_handshake();

		// ESP_REPORT_INFO("compute_load_handshake %u %u",
		// 		filter_chunk, input_chunk);

		bool no_first_row = (input_chunk != 0);
		bool no_last_row = (input_chunk != total_input_chunks - 1);
		uint16_t first_row_to_load = (max_cacheable_rows - 2) * input_chunk;
		uint16_t loadable_rows = min(height - first_row_to_load,
					     max_cacheable_rows);
		uint16_t rows_to_load = loadable_rows - no_first_row - no_last_row;
		uint16_t loadable_output_size = rows_to_load * output_w;

		for (uint16_t output_row = 0; output_row < rows_to_load; output_row++)
		{
		    for (uint16_t output_col = 0; output_col < output_w; output_col++)
		    {
			// ESP_REPORT_INFO("compute_kernel most inner loop %u %u %u %u",
			// 		filter_chunk, input_chunk, output_row, output_col);

			patch_extractor(n_channels, loadable_rows, width,
					loadable_rows * width, ping_input,
					output_row + no_first_row, output_col,
					pad, filter_dim);

			multiple_multiplier_accumulator(ping_weights, ping_bias, ping_output,
							filter_size, n_filters, filter_chunk,
							loadable_filters, plm_bias_index,
							output_row * output_w + output_col,
							loadable_output_size, do_relu);
			wait();
		    }
		}
		if (total_input_chunks != 1)
		    ping_input = !ping_input;
		ping_output = !ping_output;
		this->compute_store_handshake();
	    }
	    ping_weights = !ping_weights;
	    bias_chunk++;
	    plm_bias_index += loadable_filters;
	    if (bias_chunk == max_cacheable_bias_chunks) {
		bias_chunk = 0;
		plm_bias_index = 0;
		ping_bias = !ping_bias;
	    }
	}
    }

    // Conclude
    {
	this->process_done();
    }
}
