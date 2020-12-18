// Copyright (c) 2011-2019 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0

#include "conv2d.hpp"
#include "conv2d_directives.hpp"

// Functions

#include "conv2d_functions.hpp"

// Processes

// NOTE
// - most datatypes are custom (e.g. uint4_t), make sure you don't need more bits!

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
    uint2_t pool_type;
    uint16_t batch_size;
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
        pool_type = config.pool_type;
        batch_size = config.batch_size;
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
    uint16_t max_cacheable_rows_init;
    uint16_t max_cacheable_size;
    uint16_t max_cacheable_size_init;
    uint16_t max_cacheable_filters;
    uint16_t max_cacheable_filters_size;
    uint16_t max_cacheable_bias_chunks;
    uint16_t max_cacheable_bias_size;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    uint16_t feature_offset_incr;
    uint16_t feature_offset_incr_init;
    uint16_t channel_offset_incr;
    uint16_t out_channel_offset_incr;
    uint16_t out_channel_pool_offset_incr;
    uint32_t filters_offset_start_base;
    uint32_t feature_offset_start_base;
    uint32_t bias_offset_start_base;

    compute_dimensions(height, width, n_channels, (bool) is_padded,
		       stride, (uint8_t) filter_dim, n_filters, pool_type, batch_size,
		       &output_w, &pad, &feature_size, &filter_size, &filters_size,
		       &max_cacheable_rows, &max_cacheable_rows_init,
		       &max_cacheable_size, &max_cacheable_size_init,
		       &max_cacheable_filters,
		       &max_cacheable_filters_size, &max_cacheable_bias_chunks,
		       &max_cacheable_bias_size, &total_input_chunks, &total_filters_chunks,
		       &feature_offset_incr, &feature_offset_incr_init,
		       &channel_offset_incr, &out_channel_offset_incr, &out_channel_pool_offset_incr,
		       &filters_offset_start_base,
		       &bias_offset_start_base, &feature_offset_start_base);

    {
	HLS_DEFINE_PROTOCOL("load-config-sig");
	pad_sig.write(pad);
	output_w_sig.write(output_w);
	filter_size_sig.write(filter_size);
	total_filters_chunks_sig.write(total_filters_chunks);
	total_input_chunks_sig.write(total_input_chunks);
	max_cacheable_rows_sig.write(max_cacheable_rows);
	max_cacheable_rows_init_sig.write(max_cacheable_rows_init);
	max_cacheable_filters_sig.write(max_cacheable_filters);
	max_cacheable_bias_chunks_sig.write(max_cacheable_bias_chunks);
	out_channel_offset_incr_sig.write(out_channel_offset_incr);
	out_channel_pool_offset_incr_sig.write(out_channel_pool_offset_incr);
	feature_offset_start_base_sig.write(feature_offset_start_base);
	wait();
    }

    load_compute_cfg_handshake();
    load_store_cfg_handshake();

    // Load
    {
#ifndef STRATUS_HLS
	ESP_REPORT_INFO("output_w %u", output_w);
	ESP_REPORT_INFO("pad %u", (uint32_t) pad);
	ESP_REPORT_INFO("feature_size %u", feature_size);
	ESP_REPORT_INFO("filter_size %u", filter_size);
	ESP_REPORT_INFO("filters_size %u", filters_size);
	ESP_REPORT_INFO("max_cacheable_rows %u", max_cacheable_rows);
	ESP_REPORT_INFO("max_cacheable_rows_init %u", max_cacheable_rows_init);
	ESP_REPORT_INFO("max_cacheable_size %u", max_cacheable_size);
	ESP_REPORT_INFO("max_cacheable_size_init %u", max_cacheable_size_init);
	ESP_REPORT_INFO("max_cacheable_filters %u", max_cacheable_filters);
	ESP_REPORT_INFO("max_cacheable_filters_size %u", max_cacheable_filters_size);
	ESP_REPORT_INFO("max_cacheable_bias_chunks %u", max_cacheable_bias_chunks);
	ESP_REPORT_INFO("max_cacheable_bias_size %u", max_cacheable_bias_size);
	ESP_REPORT_INFO("total_input_chunks %u", total_input_chunks);
	ESP_REPORT_INFO("total_filters_chunks %u", total_filters_chunks);
	ESP_REPORT_INFO("feature_offset_incr %u", feature_offset_incr);
	ESP_REPORT_INFO("feature_offset_incr_init %u", feature_offset_incr_init);
	ESP_REPORT_INFO("channel_offset_incr %u", channel_offset_incr);
	ESP_REPORT_INFO("filters_offset_start_base %u", filters_offset_start_base);
	ESP_REPORT_INFO("bias_offset_start_base %u", bias_offset_start_base);
	ESP_REPORT_INFO("feature_offset_start_base %u", feature_offset_start_base);
#endif
	// Chunking
	uint32_t infeature_offset_incr = channel_offset_incr * n_channels;
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
	    bool misaligned = filters_offset_start_phys & 1 & (DMA_WORD_PER_BEAT - 1);
	    uint16_t adj_words_to_load = n_words_to_load + misaligned;

	    dma_info_t dma_info(filters_offset_start_phys >> DMA_WORD_PER_BEAT_LOG2,
				(n_words_to_load + misaligned + 1) >> DMA_WORD_PER_BEAT_LOG2,
				DMA_SIZE);

	    // ESP_REPORT_INFO("load_input load filters dma_info. offset: %u len %u",
	    // 		filters_offset_start_phys, n_words_to_load);

	    this->dma_read_ctrl.put(dma_info);

	    for (uint16_t i = 0; i < adj_words_to_load; i += DMA_WORD_PER_BEAT)
	    {
		HLS_PROTO("load-dma-filters");
		HLS_BREAK_DEP(plm_weights_ping);
		HLS_BREAK_DEP(plm_weights_pong);

		sc_dt::sc_bv<DMA_WIDTH> dataBv;

		dataBv = this->dma_read_chnl.get();
		wait();

		if (!(!i && misaligned)) { // TODO check correctness
		    if (ping_weights) {
			plm_weights_ping[plm_weights_index++] = dataBv.range(31,0).to_int();
			if (i + 1 < adj_words_to_load)
			    plm_weights_ping[plm_weights_index++] = dataBv.range(63,32).to_int();
		    } else {
			plm_weights_pong[plm_weights_index++] = dataBv.range(31,0).to_int();
			if (i + 1 < adj_words_to_load)
			    plm_weights_pong[plm_weights_index++] = dataBv.range(63,32).to_int();
		    }
		}
	    }

	    filters_offset_start_phys += n_words_to_load;
	    filters_offset_start_virt += n_words_to_load;

	    ping_weights = !ping_weights;

	    if (!bias_chunk) {
		uint16_t n_words_to_load = min(n_filters - bias_offset_start_virt,
					       max_cacheable_bias_size);
		bool misaligned = bias_offset_start_phys & 1 & (DMA_WORD_PER_BEAT - 1);
		uint16_t adj_words_to_load = n_words_to_load + misaligned;

		dma_info_t dma_info(bias_offset_start_phys >> DMA_WORD_PER_BEAT_LOG2,
				    (n_words_to_load + misaligned + 1) >> DMA_WORD_PER_BEAT_LOG2,
				    DMA_SIZE);

		// ESP_REPORT_INFO("load_input load bias dma_info. offset: %u len %u",
		// 		bias_offset_start_phys, n_words_to_load);

		this->dma_read_ctrl.put(dma_info);

		for (uint16_t i = 0; i < adj_words_to_load; i += DMA_WORD_PER_BEAT)
		{
		    HLS_PROTO("load-dma-biases");
		    HLS_BREAK_DEP(plm_bias_ping);
		    HLS_BREAK_DEP(plm_bias_pong);

		    sc_dt::sc_bv<DMA_WIDTH> dataBv;

		    dataBv = this->dma_read_chnl.get();
		    wait();

		    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
		    if (!(!i && misaligned)) {
			if (ping_bias) {
			    plm_bias_ping[plm_bias_index++] = dataBv.range(31, 0).to_int();
			    if (i + 1 < adj_words_to_load)
				plm_bias_ping[plm_bias_index++] = dataBv.range(63, 32).to_int();
			} else {
			    plm_bias_pong[plm_bias_index++] = dataBv.range(31, 0).to_int();
			    if (i + 1 < adj_words_to_load)
				plm_bias_pong[plm_bias_index++] = dataBv.range(63, 32).to_int();
			}
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

	    // Batching
	    uint32_t infeature_offset_start_base = 0;
	    for (uint16_t b = 0; b < batch_size; b++)
	    {
		uint32_t infeature_offset_start_virt = 0;
		uint32_t infeature_offset_start = infeature_offset_start_base;
		for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
		{
		    uint32_t channel_offset = 0;
		    uint16_t plm_in_index = 0;
		    uint16_t max_cacheable_size_i;
		    uint16_t feature_offset_incr_i;

		    if (single_chunk_done) {
			this->load_compute_handshake();
			break;
		    }

		    if (total_input_chunks == 1 && batch_size == 1) // optimize if multiple batches all fit in PLM
			single_chunk_done = true;

		    if (!input_chunk) {
			max_cacheable_size_i = max_cacheable_size_init;
			feature_offset_incr_i = feature_offset_incr_init;
		    } else {
			max_cacheable_size_i = max_cacheable_size;
			feature_offset_incr_i = feature_offset_incr;
		    }

		    for (uint16_t ch = 0; ch < n_channels; ch++)
		    {
			wait();

			// Configure DMA transaction
			uint32_t offset_start = channel_offset + infeature_offset_start;
			uint16_t n_words_to_load = min(feature_size - infeature_offset_start_virt,
						       max_cacheable_size_i);
			bool misaligned = offset_start & 1 & (DMA_WORD_PER_BEAT - 1);
			uint16_t adj_words_to_load = n_words_to_load + misaligned;

			dma_info_t dma_info(offset_start >> DMA_WORD_PER_BEAT_LOG2,
					    (n_words_to_load + 1) >> DMA_WORD_PER_BEAT_LOG2, DMA_SIZE);

			// ESP_REPORT_INFO("load_input load features dma_info. offset: %u len %u",
			// 		offset_start, n_words_to_load);

			this->dma_read_ctrl.put(dma_info);

			for (uint16_t i = 0; i < adj_words_to_load; i += DMA_WORD_PER_BEAT)
			{
			    HLS_PROTO("load-dma-in-features");
			    HLS_BREAK_DEP(plm_in_ping);
			    HLS_BREAK_DEP(plm_in_pong);

			    sc_dt::sc_bv<DMA_WIDTH> dataBv;

			    dataBv = this->dma_read_chnl.get();
			    wait();

			    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
			    if (!(!i && misaligned)) {
				if (ping_input) {
				    plm_in_ping[plm_in_index++] = dataBv.range(31, 0).to_int();
				    if (i + 1 < adj_words_to_load)
					plm_in_ping[plm_in_index++] = dataBv.range(63, 32).to_int();
				} else {
				    plm_in_pong[plm_in_index++] = dataBv.range(31, 0).to_int();
				    if (i + 1 < adj_words_to_load)
					plm_in_pong[plm_in_index++] = dataBv.range(63, 32).to_int();
				}
			    }
			}
			channel_offset += channel_offset_incr;
		    }

		    ping_input = !ping_input;
		    infeature_offset_start += feature_offset_incr_i;
		    infeature_offset_start_virt += feature_offset_incr_i;

		    this->load_compute_handshake();
		}
		infeature_offset_start_base += infeature_offset_incr;
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
    uint2_t pool_type;
    uint16_t batch_size;

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
	pool_type = config.pool_type;
	batch_size = config.batch_size;
    }

    store_load_cfg_handshake();

    uint4_t pad;
    uint16_t output_w;
    uint16_t max_cacheable_rows;
    uint16_t max_cacheable_rows_init;
    uint16_t max_cacheable_filters;
    uint16_t total_input_chunks;
    uint16_t total_filters_chunks;
    uint16_t out_channel_offset_incr;
    uint16_t out_channel_pool_offset_incr;
    uint32_t feature_offset_start_base;

    {
	HLS_DEFINE_PROTOCOL("store-config-sig");
	pad = pad_sig.read();
	output_w = output_w_sig.read();
	total_filters_chunks = total_filters_chunks_sig.read();
	total_input_chunks = total_input_chunks_sig.read();
	max_cacheable_rows = max_cacheable_rows_sig.read();
	max_cacheable_rows_init = max_cacheable_rows_init_sig.read();
	max_cacheable_filters = max_cacheable_filters_sig.read();
	out_channel_offset_incr = out_channel_offset_incr_sig.read();
	out_channel_pool_offset_incr = out_channel_pool_offset_incr_sig.read();
	feature_offset_start_base = feature_offset_start_base_sig.read();
	wait();
    }

    bool ping_output = true;
    bool is_pool = pool_type ? true : false;

    // Store
    uint32_t out_channel_offset_base = 0;
    uint32_t feature_offset_start_base_tmp = feature_offset_start_base;
    for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
    {
	wait();
	for (uint16_t b = 0; b < batch_size; b++)
	{
	    uint32_t feature_offset_start_phys = feature_offset_start_base_tmp;
	    uint32_t feature_offset_start_virt = 0;
	    uint16_t first_row_to_load = 0;
	    for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
	    {
		uint16_t max_cacheable_rows_i;
		if (!input_chunk) {
		    max_cacheable_rows_i = max_cacheable_rows_init;
		} else {
		    max_cacheable_rows_i = max_cacheable_rows;
		}

		bool no_first_row = (input_chunk != 0);
		bool no_last_row = (input_chunk != total_input_chunks - 1);
		uint16_t loadable_rows = min(height - first_row_to_load,
					     max_cacheable_rows_i);
		uint16_t rows_to_load = loadable_rows - (no_first_row * pad) - (no_last_row * pad);
		uint16_t rows_to_load_adj = (uint16_t) (rows_to_load + stride - 1)
		    >> ilog2(stride);
		uint16_t rows_to_load_adj_pool = (uint16_t) rows_to_load_adj >> is_pool;
		uint16_t n_words_to_store = rows_to_load_adj_pool *
		    ((uint16_t) output_w >> is_pool);

		uint16_t plm_out_index = 0;
		uint16_t cached_filters = min(max_cacheable_filters,
					      n_filters - filter_chunk * max_cacheable_filters);
		uint32_t out_channel_offset = out_channel_offset_base;

		this->store_compute_handshake();

		// pooling step
		for (uint16_t filter_i = 0; filter_i < cached_filters; filter_i++) {
		    uint32_t offset_start = out_channel_offset + feature_offset_start_phys;

		    if (pool_type) {
			uint16_t pool_i_in1_base = filter_i * round_up(rows_to_load_adj * output_w,
								       DMA_WORD_PER_BEAT);
			uint16_t pool_i_in2_base = pool_i_in1_base + output_w;
			uint16_t pool_i_out = filter_i * round_up(n_words_to_store,
								  DMA_WORD_PER_BEAT);

			// std::cout << "pool_i_in1_base " << pool_i_in1_base << " pool_i_out_base "
			// 	  << pool_i_out <<std::endl;

			for (uint16_t out_h = 0; out_h < rows_to_load_adj - 1; out_h += 2) {
			    uint16_t pool_i_in1 = pool_i_in1_base;
			    uint16_t pool_i_in2 = pool_i_in2_base;
			    for (uint16_t out_w = 0; out_w < output_w - 1; out_w += 2) {
				// HLS_BREAK_DEP(plm_out_ping);
				// HLS_BREAK_DEP(plm_out_pong);
				// HLS_PIPELINE_LOOP(HARD_STALL, 8, "pool-pipeline");

				FPDATA a, b, c, d, res;
				if (ping_output) {
				    a = INT2FP(plm_out_ping[pool_i_in1]);
				    b = INT2FP(plm_out_ping[pool_i_in1 + 1]);
				    c = INT2FP(plm_out_ping[pool_i_in2]);
				    d = INT2FP(plm_out_ping[pool_i_in2 + 1]);
				} else {
				    a = INT2FP(plm_out_pong[pool_i_in1]);
				    b = INT2FP(plm_out_pong[pool_i_in1 + 1]);
				    c = INT2FP(plm_out_pong[pool_i_in2]);
				    d = INT2FP(plm_out_pong[pool_i_in2 + 1]);
				}
				pool_i_in1 += 2;
				pool_i_in2 += 2;

				if (pool_type == 1) {
				    if (a >= b && a >= c && a >= d) {
					res = a;
				    } else if (b >= c && b >= d) {
					res = b;
				    } else if (c >= d) {
					res = c;
				    } else {
					res = d;
				    }
				} else { // pool_type == 2
				    res = (a + b + c + d) * 0.25;
				}
				    
				if (ping_output) {
				    plm_out_ping[pool_i_out++] = FP2INT(res);
				} else {
				    plm_out_pong[pool_i_out++] = FP2INT(res);
				}
			    }
			    pool_i_in1_base += (output_w << 1);
			    pool_i_in2_base += (output_w << 1);
			}
		    }

		    {
			HLS_DEFINE_PROTOCOL();

			dma_info_t dma_info(offset_start >> DMA_WORD_PER_BEAT_LOG2,
					    (n_words_to_store + 1) >> DMA_WORD_PER_BEAT_LOG2,
					    DMA_SIZE);
			// ESP_REPORT_INFO("store dma info. offset: %u len %u",
			// 		offset_start, n_words_to_store);

			this->dma_write_ctrl.put(dma_info);

			for (uint16_t i = 0; i < n_words_to_store; i += DMA_WORD_PER_BEAT)
			{
			    HLS_PROTO("store-dma-out-features");
			    HLS_BREAK_DEP(plm_out_ping);
			    HLS_BREAK_DEP(plm_out_pong);

			    wait();

			    sc_dt::sc_bv<DMA_WIDTH> dataBv;

			    // Write to PLM (all DMA_WORD_PER_BEAT words in one cycle)
			    if (ping_output) {
				// std::cout << "store ping " <<
				// 	INT2FP(plm_out_ping[plm_out_index]) << std::endl;
				dataBv.range(31, 0) = plm_out_ping[plm_out_index++];
				dataBv.range(63, 32) = plm_out_ping[plm_out_index++];
			    } else {
				// std::cout << "store pong " <<
				// 	INT2FP(plm_out_pong[plm_out_index]) << std::endl;
				dataBv.range(31, 0) = plm_out_pong[plm_out_index++];
				dataBv.range(63, 32) = plm_out_pong[plm_out_index++];
			    }

			    this->dma_write_chnl.put(dataBv);
			}
		    }
		    out_channel_offset += out_channel_pool_offset_incr;
		}
		ping_output = !ping_output;
		feature_offset_start_phys += n_words_to_store;
		feature_offset_start_virt += n_words_to_store;
		first_row_to_load += max_cacheable_rows_i - (filter_dim - 1);
	    }
	    feature_offset_start_base_tmp += (n_filters * out_channel_pool_offset_incr);
	}
	out_channel_offset_base += (out_channel_pool_offset_incr * max_cacheable_filters);
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
    uint2_t stride;
    uint16_t height;
    uint16_t width;
    bool do_relu;
    uint2_t pool_type;
    uint16_t batch_size;

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
	pool_type = config.pool_type;
	batch_size = config.batch_size;
    }

    compute_load_cfg_handshake();

    uint4_t pad;
    uint16_t output_w;
    uint16_t filter_size;
    uint16_t max_cacheable_rows;
    uint16_t max_cacheable_rows_init;
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
	max_cacheable_rows_init = max_cacheable_rows_init_sig.read();
	max_cacheable_filters = max_cacheable_filters_sig.read();
	max_cacheable_bias_chunks = max_cacheable_bias_chunks_sig.read();
	wait();
    }

    // Compute
    bool ping_input = true;
    bool ping_weights = true;
    bool ping_bias = true;
    bool ping_output = true;

    uint16_t bias_chunk = 0;
    uint16_t plm_bias_index = 0;
    for (uint16_t filter_chunk = 0; filter_chunk < total_filters_chunks; filter_chunk++)
    {
	uint16_t loadable_filters = min(n_filters - filter_chunk * max_cacheable_filters,
					max_cacheable_filters);
	for (uint16_t b = 0; b < batch_size; b++)
	{
	    uint16_t first_row_to_load = 0;
	    for (uint16_t input_chunk = 0; input_chunk < total_input_chunks; input_chunk++)
	    {
		this->compute_load_handshake();

		// ESP_REPORT_INFO("compute_load_handshake %u %u",
		// 		filter_chunk, input_chunk);

		uint16_t max_cacheable_rows_i;
		if (!input_chunk) {
		    max_cacheable_rows_i = max_cacheable_rows_init;
		} else {
		    max_cacheable_rows_i = max_cacheable_rows;
		}

		bool no_first_row = (input_chunk != 0);
		bool no_last_row = (input_chunk != total_input_chunks - 1);
		uint16_t loadable_rows = min(height - first_row_to_load,
					     max_cacheable_rows_i);
		uint16_t rows_to_load = loadable_rows - (no_first_row * pad) - (no_last_row * pad);
		uint16_t loadable_output_size =
		    round_up(((uint16_t) (rows_to_load + stride - 1) >>
			      ilog2(stride)) * output_w, DMA_WORD_PER_BEAT);

		uint16_t output_plm_offset = 0;
		for (uint16_t output_row = 0; output_row < rows_to_load; output_row += stride)
		{
		    for (uint16_t output_col = 0; output_col < (output_w << ilog2(stride));
			 output_col += stride)
		    {
			// ESP_REPORT_INFO("compute_kernel most inner loop %u %u %u %u",
			// 		filter_chunk, input_chunk, output_row, output_col);

			patch_extractor(
			    n_channels, loadable_rows, width, loadable_rows * width, ping_input,
			    output_row + (no_first_row * pad), output_col, pad, filter_dim);

			multiple_multiplier_accumulator(
			    ping_weights, ping_bias, ping_output, filter_size, n_filters,
			    filter_chunk, loadable_filters, plm_bias_index, output_plm_offset,
			    loadable_output_size, do_relu);

			output_plm_offset++;
			wait();
		    }
		}
		first_row_to_load += max_cacheable_rows_i - (filter_dim - 1);
		if (total_input_chunks != 1 || batch_size != 1)
		    ping_input = !ping_input;
		ping_output = !ping_output;
		this->compute_store_handshake();
	    }
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

    // Conclude
    {
	this->process_done();
    }
}
