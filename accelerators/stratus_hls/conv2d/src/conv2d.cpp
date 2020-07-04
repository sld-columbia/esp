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

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int16_t n_channels;
    int16_t n_filters;
    int8_t filter_height;
    int8_t dilation_h;
    int8_t stride_w;
    int8_t pad_w;
    int16_t feature_map_height;
    int8_t pad_h;
    int8_t stride_h;
    int8_t filter_width;
    int8_t dilation_w;
    int16_t feature_map_width;
    {
        HLS_PROTO("load-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_height = config.filter_height;
        dilation_h = config.dilation_h;
        stride_w = config.stride_w;
        pad_w = config.pad_w;
        feature_map_height = config.feature_map_height;
        pad_h = config.pad_h;
        stride_h = config.stride_h;
        filter_width = config.filter_width;
        dilation_w = config.dilation_w;
        feature_map_width = config.feature_map_width;
    }

    // Precompute sizes
    uint16_t output_h;
    uint16_t output_w;
    uint16_t filter_size;
    uint8_t max_cacheable_rows;
    uint8_t max_cacheable_filters;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    compute_dimensions(feature_map_height, feature_map_width, n_channels, pad_h, pad_w,
		       stride_h, stride_w, dilation_h, dilation_w, (uint8_t) filter_height,
		       (uint8_t) filter_width, n_filters, &output_h, &output_w, &filter_size,
		       &max_cacheable_rows, &max_cacheable_filters, &total_input_chunks,
		       &total_filters_chunks);


    bool ping_input = true;
    bool ping_weights = true;
    uint16_t feature_offset_incr = (max_cacheable_rows - 2) * feature_map_width;
    uint16_t feature_size = feature_map_height * feature_map_width;
    uint16_t channel_offset_incr = feature_size;
    uint16_t filters_size = filter_size * n_filters;
    uint16_t max_cacheable_filters_size = filter_size * max_cacheable_filters;
    uint16_t filters_offset_start_base = feature_size * n_channels;

    // Load
    {
        HLS_PROTO("load-dma");
        wait();

	// ESP_REPORT_INFO("output_h %u", output_h);
	// ESP_REPORT_INFO("output_w %u", output_w);
	// ESP_REPORT_INFO("filter_size %u", filter_size);
	// ESP_REPORT_INFO("max_cacheable_rows %u", max_cacheable_rows);
	// ESP_REPORT_INFO("max_cacheable_filters %u", max_cacheable_filters);
	// ESP_REPORT_INFO("total_input_chunks %u", total_input_chunks);
	// ESP_REPORT_INFO("total_filters_chunks %u", total_filters_chunks);
	// ESP_REPORT_INFO("feature_offset_incr %u", feature_offset_incr);
	// ESP_REPORT_INFO("feature_size %u", feature_size);
	// ESP_REPORT_INFO("channel_offset_incr %u", channel_offset_incr);
	// ESP_REPORT_INFO("filters_size %u", filters_size);
	// ESP_REPORT_INFO("max_cacheable_filters_size %u", max_cacheable_filters_size);

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();

            // Chunking
	    uint16_t filters_offset_start_phys = filters_offset_start_base;
	    uint16_t filters_offset_start_virt = 0;
	    for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	    {
		uint16_t plm_weights_index = 0;
		uint16_t n_words_to_load = min(filters_size - filters_offset_start_virt,
					       max_cacheable_filters_size);

		dma_info_t dma_info(filters_offset_start_phys / DMA_WORD_PER_BEAT,
				    n_words_to_load / DMA_WORD_PER_BEAT, DMA_SIZE);

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

		uint16_t feature_offset_start = 0;

		for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
		{
		    uint16_t channel_offset = 0;
		    uint16_t plm_in_index = 0;
		    for (uint16_t ch = 0; ch < n_channels; ch++)
		    {
			wait();

			// Configure DMA transaction
			uint16_t n_words_to_load = min(feature_size - feature_offset_start,
						       feature_offset_incr);
			uint16_t offset_start = channel_offset + feature_offset_start;
			dma_info_t dma_info(offset_start / DMA_WORD_PER_BEAT,
					    n_words_to_load / DMA_WORD_PER_BEAT, DMA_SIZE);

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

            // // Chunking
	    // for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++) {
            // // for (int rem = length; rem > 0; rem -= INPUT_PLM_SIZE)
            // {
	    // 	uint16_t channel_offset = 0;
	    // 	uint16_t plm_in_index = 0;
	    // 	for (uint16_t ch = 0; ch < channels; ch++)
	    // 	{
	    // 	    wait();

	    // 	    // Configure DMA transaction
	    // 	    uint16_t n_words_to_load = min(feature_size - feature_offset_start,
	    // 					   feature_offset_incr);
	    // 	    uint16_t offset_start = channel_offset + feature_offset_start;
	    // 	    dma_info_t dma_info(offset_start / DMA_WORD_PER_BEAT,
	    // 				n_words_to_load / DMA_WORD_PER_BEAT, DMA_SIZE);

	    // 	    this->dma_read_ctrl.put(dma_info);

	    // 	    for (uint16_t i = 0; i < n_words_to_load; i += DMA_WORD_PER_BEAT)
	    // 	    {
	    // 		HLS_BREAK_DEP(plm_in_ping);
	    // 		HLS_BREAK_DEP(plm_in_pong);

	    // 		sc_dt::sc_bv<DMA_WIDTH> dataBv;

	    // 		dataBv = this->dma_read_chnl.get();
	    // 		wait();

	    // 		// Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
	    // 		for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
	    // 		{
	    // 		    HLS_UNROLL_SIMPLE;
	    // 		    if (ping_input)
	    // 			plm_in_ping[plm_in_index++] =
	    // 			    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
	    // 		    else
	    // 			plm_in_pong[plm_in_index++] =
	    // 			    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
	    // 		}
	    // 	    }

	    // 	    channel_offset += channel_offset_incr;
	    // 	}

	    // 	ping_input = !ping_input;
	    // 	feature_offset_start += feature_offset_incr;

	    // 	uint16_t filters_offset_start = 0;
	    // 	for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	    // 	{
	    // 	    uint16_t plm_weights_index = 0;
	    // 	    uint16_t n_words_to_load = min(filters_size - filters_offset_start,
	    // 					   max_cacheable_filters_size);

	    // 	    dma_info_t dma_info(filters_offset_start / DMA_WORD_PER_BEAT,
	    // 				n_words_to_load / DMA_WORD_PER_BEAT, DMA_SIZE);

	    // 	    this->dma_read_ctrl.put(dma_info);

	    // 	    for (uint16_t i = 0; i < n_words_to_load; i += DMA_WORD_PER_BEAT)
	    // 	    {
	    // 		HLS_BREAK_DEP(plm_weights_ping);
	    // 		HLS_BREAK_DEP(plm_weights_pong);

	    // 		sc_dt::sc_bv<DMA_WIDTH> dataBv;

	    // 		dataBv = this->dma_read_chnl.get();
	    // 		wait();

	    // 		// Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
	    // 		for (uint16_t k = 0; k < DMA_WORD_PER_BEAT; k++)
	    // 		{
	    // 		    HLS_UNROLL_SIMPLE;
	    // 		    if (ping_weights)
	    // 			plm_weights_ping[plm_weights_index++] =
	    // 			    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
	    // 		    else
	    // 			plm_weights_pong[plm_weights_index++] =
	    // 			    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH).to_int64();
	    // 		}
	    // 	    }

	    // 	    filters_offset_start += n_words_to_load;

	    //      ping_weights = !ping_weights;
	    // 	    this->load_compute_handshake();
	    // 	}
	    // }
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

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int16_t n_channels;
    int16_t n_filters;
    int8_t filter_height;
    int8_t dilation_h;
    int8_t stride_w;
    int8_t pad_w;
    int16_t feature_map_height;
    int8_t pad_h;
    int8_t stride_h;
    int8_t filter_width;
    int8_t dilation_w;
    int16_t feature_map_width;

    {
        HLS_PROTO("store-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_height = config.filter_height;
        dilation_h = config.dilation_h;
        stride_w = config.stride_w;
        pad_w = config.pad_w;
        feature_map_height = config.feature_map_height;
        pad_h = config.pad_h;
        stride_h = config.stride_h;
        filter_width = config.filter_width;
        dilation_w = config.dilation_w;
        feature_map_width = config.feature_map_width;
    }

    // Precompute sizes
    uint16_t output_h;
    uint16_t output_w;
    uint16_t filter_size;
    uint8_t max_cacheable_rows;
    uint8_t max_cacheable_filters;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    compute_dimensions(feature_map_height, feature_map_width, n_channels, pad_h, pad_w,
		       stride_h, stride_w, dilation_h, dilation_w, (uint8_t) filter_height,
		       (uint8_t) filter_width, n_filters, &output_h, &output_w, &filter_size,
		       &max_cacheable_rows, &max_cacheable_filters, &total_input_chunks,
		       &total_filters_chunks);


    bool ping_output = true;
    uint16_t feature_offset_incr = (max_cacheable_rows - 2) * feature_map_width;
    uint16_t feature_size = feature_map_height * feature_map_width;
    uint16_t channel_offset_incr = feature_size;
    uint16_t filters_size = filter_size * n_filters;
    uint16_t max_cacheable_filters_size = filter_size * max_cacheable_filters;
    uint16_t feature_offset_start_base = feature_size * n_channels + filters_size;

    // Store
    {
        HLS_PROTO("store-dma");
        wait();

        // Batching
        for (uint16_t b = 0; b < 1; b++)
        {
            wait();

	    for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	    {
		wait();

		uint16_t feature_offset_start_phys = feature_offset_start_base;
		uint16_t feature_offset_start_virt = 0;
		for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
		{
		    uint16_t channel_offset = 0;
		    uint16_t plm_out_index = 0;

		    this->store_compute_handshake();

		    for (uint16_t filter_i = 0; filter_i < min(n_filters, max_cacheable_filters); filter_i++) {
		
			uint16_t n_words_to_store = min(feature_size - feature_offset_start_virt,
							feature_offset_incr);
			uint16_t offset_start = channel_offset + feature_offset_start_phys;
	
			dma_info_t dma_info(offset_start / DMA_WORD_PER_BEAT,
					    n_words_to_store / DMA_WORD_PER_BEAT, DMA_SIZE);

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
				    // ESP_REPORT_INFO("store_output most inner loop: %d", (int) plm_out_ping[plm_out_index]);
				    dataBv.range((k+1) * DATA_WIDTH - 1, k * DATA_WIDTH) =
					plm_out_ping[plm_out_index++];
				} else {
				    // ESP_REPORT_INFO("store_output most inner loop: %d", (int) plm_out_pong[plm_out_index]);
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
		    feature_offset_start_phys += feature_offset_incr;
		    feature_offset_start_virt += feature_offset_incr;
		}
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

        // explicit PLM ports reset if any

        // User-defined reset code

        wait();
    }

    // Config
    /* <<--params-->> */
    int16_t n_channels;
    int16_t n_filters;
    int8_t filter_height;
    int8_t dilation_h;
    int8_t stride_w;
    int8_t pad_w;
    int16_t feature_map_height;
    int8_t pad_h;
    int8_t stride_h;
    int8_t filter_width;
    int8_t dilation_w;
    int16_t feature_map_width;

    {
        HLS_PROTO("compute-config");

        cfg.wait_for_config(); // config process
        conf_info_t config = this->conf_info.read();

        // User-defined config code
        /* <<--local-params-->> */
        n_channels = config.n_channels;
        n_filters = config.n_filters;
        filter_height = config.filter_height;
        dilation_h = config.dilation_h;
        stride_w = config.stride_w;
        pad_w = config.pad_w;
        feature_map_height = config.feature_map_height;
        pad_h = config.pad_h;
        stride_h = config.stride_h;
        filter_width = config.filter_width;
        dilation_w = config.dilation_w;
        feature_map_width = config.feature_map_width;
    }

    // Precompute sizes
    uint16_t output_h;
    uint16_t output_w;
    uint16_t filter_size;
    uint8_t max_cacheable_rows;
    uint8_t max_cacheable_filters;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    compute_dimensions(feature_map_height, feature_map_width, n_channels, pad_h, pad_w,
		       stride_h, stride_w, dilation_h, dilation_w, (uint8_t) filter_height,
		       (uint8_t) filter_width, n_filters, &output_h, &output_w, &filter_size,
		       &max_cacheable_rows, &max_cacheable_filters, &total_input_chunks,
		       &total_filters_chunks);

    // Compute
    bool ping_input = true;
    bool ping_weights = true;
    bool ping_output = true;

    for (uint16_t b = 0; b < 1; b++)
    {
	wait();
	
	for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
	{
	    uint16_t loadable_filters = min(n_filters - filter_chunk * max_cacheable_filters,
					    max_cacheable_filters);
	    for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
	    {
		uint16_t skip_first_row = (input_chunk xor 0) && 1;
		uint16_t first_row_to_load = max_cacheable_rows * input_chunk;
		uint16_t loadable_rows = min(feature_map_height - first_row_to_load,
					     max_cacheable_rows);
		uint16_t loadable_output_size = loadable_rows * output_w;

		this->compute_load_handshake();

		for (uint16_t output_row = 0; output_row < loadable_rows-skip_first_row; output_row++)
		{
		    for (uint16_t output_col = 0; output_col < output_w; output_col++)
		    {
			// ESP_REPORT_INFO("compute_kernel most inner loop %u %u %u %u",
			// 		filter_chunk, input_chunk, output_row, output_col);

			patch_extractor(n_channels, loadable_rows, feature_map_width,
					loadable_rows * feature_map_width, ping_input,
					output_row + skip_first_row, output_col,
					pad_h, pad_w, dilation_h, dilation_w,
					filter_height, filter_width);

			multiple_multiplier_accumulator(ping_weights, ping_output,
							filter_size, n_filters, filter_chunk,
							max_cacheable_filters,
							output_row * output_w + output_col,
							loadable_output_size);
			wait();
		    }
		}
		ping_input = !ping_input;

		this->compute_store_handshake();
	    }
	    ping_weights = !ping_weights;
	}
    }

    // Conclude
    {
	this->process_done();
    }
}
